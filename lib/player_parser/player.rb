require 'date'
require 'full-name-splitter'
require 'json/ext'
require 'nokogiri'
require 'remove_accents'

require 'player_parser/stats'

module PlayerParser
  class Player
    attr_reader :first_name, :middle_name, :last_name

    def initialize(html)
      page         = Nokogiri::HTML(html)

      full_name    = page.css('#player_name').first.text.removeaccents
      first, last  = FullNameSplitter::split(full_name)
      first        = first.split
      @first_name  = first.shift
      @last_name   = last
      @middle_name = first.join(' ')

      birthday     = page.css('#necro-birth').attr('data-birth').text.split('-')
      birthday.map!(&:to_i)
      @birthday    = Date.civil(*birthday)
      @age = (Date::today - @birthday).to_i / 365


      @schools     = page.css('a[href^="/schools/index.cgi?key_school="]').map(&:text)
      @position    = page.css('span[itemprop="role"]').first.text.downcase

      ident        = @position == 'pitcher' ? 'pitching' : 'batting'
      @stats       = PlayerParser::Stats.new(page, "#{ident}_standard")
    end

    def to_hash
      {
        first_name: @first_name,
        middle_name: @middle_name,
        last_name: @last_name,
        birthday: Date._parse(@birthday.iso8601),
        age: @age,
        schools: @schools,
        position: @position,
        stats: @stats.seasons.each_pair.reduce({}) do |hash, key_and_val|
          key, val = key_and_val
          hash[key] = val.to_hash
          hash
        end
      }
    end

    def to_json
      to_hash.to_json
    end

    private
  end
end
