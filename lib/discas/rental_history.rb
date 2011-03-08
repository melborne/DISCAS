#-*-encoding: utf-8-*-
require "nokogiri"

module Discas
  class RentalHistory
    attr_reader :rentals
    def initialize(base_file_path)
      @path = path(base_file_path)
      @rentals = []
    end

    def read(last_page=1, sortable=true)
      (1..last_page).each do |i|
        open(@path[i]) do |f|
          html = Nokogiri::HTML(f)
          scrape_record(html, sortable)
        end
      end
      true
    rescue => e
      STDERR.puts "File read error!: #{e}"
    end

    def write(f, header=HEADER(), sep=',')
      open(f, 'w') do |f|
        f.puts header if header
        rentals.each { |re| f.puts re.join(sep) }
      end
      true
    rescue => e
      STDERR.puts 'File write error!: #{e}'
    end

    private
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
          when i == 4             # title field
            media = td.at("img").attr('title')
            data = td.at("a").text
            url = td.at("a").attr('href')
            record << media << data << url
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
