module DocBase
  class Client
    DEFAULT_URL = 'https://api.docbase.io'
    USER_AGENT = "DocBase Ruby Gem #{DocBase::VERSION}"

    class NotSetTeamError < StandardError; end

    attr_accessor :team

    def initialize(access_token: nil, url: nil, team: nil)
      @access_token = access_token || ENV['DOCBASE_ACCESS_TOKEN']
      self.team = team
      @url = url || DEFAULT_URL
    end

    def team!
      raise NotSetTeamError unless @team
      @team
    end

    def teams
      connection.get('/teams')
    end

    def tags
      connection.get("/teams/#{team!}/tags")
    end

    def groups
      connection.get("/teams/#{team!}/groups")
    end

    def post(id)
      connection.get("/teams/#{team!}/posts/#{id}")
    end

    def posts(q: '*')
      connection.get("/teams/#{team!}/posts", q: q)
    end

    def create_post(params)
      connection.post("/teams/#{team!}/posts", params)
    end

    def connection
      @connection ||= Faraday.new({ url: @url, headers: headers }) do |faraday|
        faraday.request :json
        faraday.response :json
        faraday.adapter Faraday.default_adapter
      end
    end

    def headers
      {
        'Accept'         => 'application/json',
        'User-Agent'     => USER_AGENT,
        'X-DocBaseToken' => @access_token,
      }
    end
  end
end
