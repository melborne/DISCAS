#-*-encoding: utf-8-*-
require "nokogiri"

module Discas
  class RentalHistory
    attr_reader :rentals
    def initialize(base_file_path)
      @path = path(base_file_path)
      @rentals = []
    end

    def read(pages=nil, sortable=true)
      @rentals.clear
      build_range(pages).each do |i|
        open(@path[i]) do |f|
          html = Nokogiri::HTML(f)
          scrape_record(html, sortable)
        end
      end
      self
    rescue => e
      STDERR.puts "File read error!: #{e}"
    end

    def write(f, header=HEADER(), sep=',')
      open(f, 'w') do |f|
        f.puts header if header
        rentals.each { |re| f.puts re.join(sep) }
      end
      self
    rescue => e
      STDERR.puts "File write error!: #{e}"
    end

    private
    def build_range(pages)
      case pages
      when Integer then (1..pages)
      when Range   then pages
      when nil     then (1..1)
      else raise ArgumentError, "Argument type is wrong!"
      end
    end

    def path(path)
      dir, base, ext = File.dirname(path), File.basename(path, '.*'), File.extname(path)
      ->n{ n = nil if n==1; File.join(dir, "#{base}#{n}#{ext}") }
    end

    def scrape_record(html, sortable)
      html.search(BASE_TR()).each do |tr|
        record = []
        tr.search("td").each_with_index do |td, i|
          case
          when [1,2,3,5].include?(i) # sent-date, return-date, status, plan fields
            record << td.text.gsub(/\t|\n/, '')
          when i == 4                # title field
            media = td.at("img").attr('title')
            title = sortable ? add_zero_to_1_to_9(td.at("a").text) : td.at("a").text
            url = td.at("a").attr('href')
            record << media << title << url
          end
        end
        @rentals << record unless record.empty?
      end
    end

    def BASE_TR
      "table.ppdis00185Tbl03[summary='これまでにご利用頂いたDVD/CD'] tr"
    end

    def HEADER
      "発送日,返却日,ステータス,メディア,タイトル,URL,プラン"
    end

    # to be series sortable, append zero to 1-9
    def add_zero_to_1_to_9(str)
      str.sub(/(?<=\D)\d\D?$/, '0\0' )
    end
  end  
end
