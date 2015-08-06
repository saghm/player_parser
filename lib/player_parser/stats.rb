require 'nokogiri'

require 'player_parser/season'

module PlayerParser
  class Stats
    attr_reader :seasons

    def initialize(page, id)
      @page = Nokogiri::HTML(page)
      @id   = id
      parse_table
    end

    private

    def parse_table
      table        = @page.css("table##{@id}").first
      headers      = table.css('thead').first
      data_headers = headers.css('th').each_with_index.select { |d, _| d.has_attribute?('data-name') }
      data_headers.map! { |d, i| [d.attr('data-stat').downcase, i] }
      seasons      = table.css('tr.full[id^="pitching_standard."]')

      @seasons = seasons.reduce({}) do |hash, season|
        /[^\.]*\.(?<year>.*)/ =~ season.attr('id')
        hash[year.to_i] = Season.new(data_headers, season)
        hash
      end
    end
  end
end
