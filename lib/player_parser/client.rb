require 'httpclient'

require 'player_parser/player'

module PlayerParser
  class Client
    def initialize
      @http = HTTPClient.new
    end

    def each_active_player
      get_all_active_player_links do |link|
        response = @http.get(link)
        next unless response.ok?
        yield PlayerParser::Player.new(response.body)
      end
    end


    private

    def get_active_players_links_for_letter(letter)
      # puts "letter"
      # Since baseball-reference.com is slow, and since lacking the trailing
      # slash redirects to the trailing slash, it's better to send the request
      # directly to the trailing slash URL.
      response = @http.get("http://www.baseball-reference.com/players/#{letter}/")
      html = Nokogiri::HTML(response.body)
      players = html.css('blockquote pre b a')
      players.map { |p| "http://www.baseball-reference.com/#{p.attr('href')}" }
    end

    def get_all_active_player_links
      ('a'..'z').lazy.each do |letter|
        get_active_players_links_for_letter(letter).lazy.each { |link| yield link }
      end
    end
  end
end
