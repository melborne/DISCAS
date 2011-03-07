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

    def write(f, header="発送日,返却日,メディア,タイトル", sep=',')
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

    # extract sent-date, return-date, media, title
    def scrape_record(html, sortable)
      html.search(BASE_TR()).each do |tr|
        record = []
        tr.search("td").each_with_index do |td, i|
          if [1,2,4].include?(i)
            data = td.text.gsub(/\t|\n/, '')
            if i == 4
              data = add_zero_to_1_to_9(data) if sortable
              record << td.at("img").attr('title')
            end
            record << data
          end
        end
        @rentals << record unless record.empty?
      end
    end

    def BASE_TR
      "table.ppdis00185Tbl03[summary='これまでにご利用頂いたDVD/CD'] tr"
    end

    # to be series sortable, append zero to 1-9
    def add_zero_to_1_to_9(str)
      str.sub(/(?<=\D)\d\D?$/, '0\0' )
    end
  end  
end
