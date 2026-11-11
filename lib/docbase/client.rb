module DocBase
  class Client
    DEFAULT_URL = 'https://api.docbase.io'
    TEAM_FORMAT = /\A[a-z0-9]+(-[a-z0-9]+)*\z/
    ID_FORMAT = /\A[1-9][0-9]*\z/
    USER_AGENT = "DocBase Ruby Gem #{DocBase::VERSION}"
    MAX_RATE_LIMIT_RETRIES = 3
    MAX_RATE_LIMIT_WAIT_SECONDS = 60

    class NotSetTeamError < StandardError; end
    class NotSetPostIdError < StandardError; end
    class TooManyRequestError < StandardError; end

    attr_accessor :team, :access_token, :retry_on_rate_limit_exceeded

    def initialize(access_token: nil, url: nil, team: nil, retry_on_rate_limit_exceeded: false)
      self.access_token = access_token
      self.team = team
      @url = url || DEFAULT_URL
      self.retry_on_rate_limit_exceeded = retry_on_rate_limit_exceeded
    end

    def team!
      raise NotSetTeamError unless @team
      raise ArgumentError, "invalid team: #{@team.inspect}" unless TEAM_FORMAT.match?(@team.to_s)

      @team
    end

    def profile
      request(method: :get, path: "/teams/#{team!}/profile")
    end

    def users(q: nil, page: 1, per_page: 100)
      request(
        method: :get,
        path: "/teams/#{team!}/users",
        params: { q: q, page: page, per_page: per_page }
      )
    end

    def user_groups(user_id, page: 1, per_page: 20)
      request(
        method: :get,
        path: "/teams/#{team!}/users/#{id_segment(user_id)}/groups",
        params: { page: page, per_page: per_page }
      )
    end

    def delete_user(id)
      request(method: :delete, path: "/teams/#{team!}/users/#{id_segment(id)}")
    end

    def tags
      request(method: :get, path: "/teams/#{team!}/tags")
    end

    def groups(name: nil, page: 1, per_page: 100)
      request(method: :get, path: "/teams/#{team!}/groups", params: { name: name, page: page, per_page: per_page })
    end

    def group(id)
      request(method: :get, path: "/teams/#{team!}/groups/#{id_segment(id)}")
    end

    def create_group(params)
      request(method: :post, path: "/teams/#{team!}/groups", params: params)
    end

    def add_users_to_group(params)
      group_id = params[:group_id].to_i
      raise NotSetTeamError if group_id <= 0

      users_params = except(params, :group_id)
      request(method: :post, path: "/teams/#{team!}/groups/#{group_id}/users", params: users_params)
    end

    def remove_users_from_group(params)
      group_id = params[:group_id].to_i
      raise NotSetTeamError if group_id <= 0

      users_params = except(params, :group_id)
      request(method: :delete, path: "/teams/#{team!}/groups/#{group_id}/users", params: users_params)
    end

    def post(id)
      request(method: :get, path: "/teams/#{team!}/posts/#{id_segment(id)}")
    end

    def posts(q: '*', page: 1, per_page: 20)
      request(method: :get, path: "/teams/#{team!}/posts", params: { q: q, page: page, per_page: per_page })
    end

    def create_post(params)
      request(method: :post, path: "/teams/#{team!}/posts", params: params)
    end

    def update_post(params)
      post_id = params[:id].to_i
      raise NotSetPostIdError if post_id <= 0

      post_params = except(params, :id)
      request(method: :patch, path: "/teams/#{team!}/posts/#{post_id}", params: post_params)
    end

    def update_post_body(params)
      post_id = params[:id].to_i
      raise NotSetPostIdError if post_id <= 0

      body_params = except(params, :id)
      request(method: :patch, path: "/teams/#{team!}/posts/#{post_id}/body", params: body_params)
    end

    def delete_post(id)
      request(method: :delete, path: "/teams/#{team!}/posts/#{id_segment(id)}")
    end

    def archive_post(id)
      request(method: :put, path: "/teams/#{team!}/posts/#{id_segment(id)}/archive")
    end

    def unarchive_post(id)
      request(method: :put, path: "/teams/#{team!}/posts/#{id_segment(id)}/unarchive")
    end

    def comments(post_id, page: 1, per_page: 20, order: 'asc', created_after: nil, created_before: nil)
      request(
        method: :get,
        path: "/teams/#{team!}/posts/#{id_segment(post_id)}/comments",
        params: {
          page: page,
          per_page: per_page,
          order: order,
          created_after: created_after,
          created_before: created_before,
        }
      )
    end

    def create_comment(params)
      post_id = params[:post_id].to_i
      raise NotSetPostIdError if post_id <= 0

      comment_params = except(params, :post_id)
      request(method: :post, path: "/teams/#{team!}/posts/#{post_id}/comments", params: comment_params)
    end

    def delete_comment(id)
      request(method: :delete, path: "/teams/#{team!}/comments/#{id_segment(id)}")
    end

    def good_jobs(post_id, page: 1, per_page: 100, order: 'asc', created_after: nil, created_before: nil)
      request(
        method: :get,
        path: "/teams/#{team!}/posts/#{id_segment(post_id)}/good_jobs",
        params: {
          page: page,
          per_page: per_page,
          order: order,
          created_after: created_after,
          created_before: created_before,
        }
      )
    end

    def create_good_job(post_id, params = {})
      request(method: :post, path: "/teams/#{team!}/posts/#{id_segment(post_id)}/good_jobs", params: params)
    end

    def delete_good_job(post_id, good_job_id)
      request(method: :delete, path: "/teams/#{team!}/posts/#{id_segment(post_id)}/good_jobs/#{id_segment(good_job_id)}")
    end

    def upload(paths)
      paths = [paths] unless paths.instance_of?(Array)

      params = paths.map do |path|
        file = File.new(path, 'r+b')
        {
          name: file.path.split('/').last,
          content: Base64.strict_encode64(file.read),
        }
      end

      request(method: :post, path: "/teams/#{team!}/attachments", params: params)
    end

    def attachment(id)
      request(method: :get, path: "/teams/#{team!}/attachments/#{path_segment(id)}", for_binary: true)
    end

    private

    def id_segment(id)
      raise ArgumentError, "invalid id: #{id.inspect}" unless ID_FORMAT.match?(id.to_s)

      id.to_s
    end

    def path_segment(value)
      value = value.to_s
      raise ArgumentError, "invalid id: #{value.inspect}" if value.empty? || value == '.' || value == '..'

      URI.encode_www_form_component(value).gsub('+', '%20')
    end

    def except(hash, reject_key)
      hash.reject { |key, _| key == reject_key }
    end

    def connection
      @connection ||= Faraday.new({ url: @url, headers: headers }) do |faraday|
        faraday.request :json
        faraday.response :json
        faraday.adapter Faraday.default_adapter
      end
    end

    def connection_for_binary
      @connection_for_binary ||= Faraday.new({ url: @url, headers: headers }) do |faraday|
        faraday.request :json
        faraday.adapter Faraday.default_adapter
      end
    end

    def headers
      {
        'Accept'     => 'application/json',
        'User-Agent' => USER_AGENT,
      }
    end

    def request(method:, path:, params: nil, for_binary: false)
      retries = 0
      loop do
        conn = for_binary ? connection_for_binary : connection
        response = conn.send(method, path, params, 'X-DocBaseToken' => access_token)
        return response unless retry_on_rate_limit_exceeded && response.status == 429

        reset_time = rate_limit_reset_time(response)
        return response if reset_time.nil? || retries >= MAX_RATE_LIMIT_RETRIES

        retries += 1
        wait_for(reset_time)
      end
    end

    def rate_limit_reset_time(response)
      reset_time = Integer(response.headers['x-ratelimit-reset'].to_s, exception: false)
      reset_time if reset_time && reset_time > 0
    end

    def wait_for(reset_time)
      wait_time = (reset_time - Time.now.to_i).clamp(0, MAX_RATE_LIMIT_WAIT_SECONDS)
      puts "DocBase API Rate limit exceeded: will retry at #{(Time.now + wait_time).strftime("%Y/%m/%d %H:%M:%S")}."
      sleep wait_time if wait_time > 0
    end
  end
end
