module DocBase
  class Client
    DEFAULT_URL = 'https://api.docbase.io'
    USER_AGENT = "DocBase Ruby Gem #{DocBase::VERSION}"

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
      @team
    end

    def profile
      request(method: :get, path: "/teams/#{team!}/profile")
    end

    def users(q: nil, page: 1, per_page: 100, include_user_groups: false)
      request(
        method: :get,
        path: "/teams/#{team!}/users",
        params: { q: q, page: page, per_page: per_page, include_user_groups: include_user_groups }
      )
    end

    def user_groups(user_id, page: 1, per_page: 20)
      request(
        method: :get,
        path: "/teams/#{team!}/users/#{user_id}/groups",
        params: { page: page, per_page: per_page }
      )
    end

    def delete_user(id)
      request(method: :delete, path: "/teams/#{team!}/users/#{id}")
    end

    def tags
      request(method: :get, path: "/teams/#{team!}/tags")
    end

    def groups(name: nil, page: 1, per_page: 100)
      request(method: :get, path: "/teams/#{team!}/groups", params: { name: name, page: page, per_page: per_page })
    end

    def group(id)
      request(method: :get, path: "/teams/#{team!}/groups/#{id}")
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
      request(method: :get, path: "/teams/#{team!}/posts/#{id}")
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
      request(method: :delete, path: "/teams/#{team!}/posts/#{id}")
    end

    def archive_post(id)
      request(method: :put, path: "/teams/#{team!}/posts/#{id}/archive")
    end

    def unarchive_post(id)
      request(method: :put, path: "/teams/#{team!}/posts/#{id}/unarchive")
    end

    def comments(post_id, page: 1, per_page: 20, order: 'asc', created_after: nil, created_before: nil)
      request(
        method: :get,
        path: "/teams/#{team!}/posts/#{post_id}/comments",
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
      request(method: :delete, path: "/teams/#{team!}/comments/#{id}")
    end

    def good_jobs(post_id, page: 1, per_page: 100, order: 'asc', created_after: nil, created_before: nil)
      request(
        method: :get,
        path: "/teams/#{team!}/posts/#{post_id}/good_jobs",
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
      request(method: :post, path: "/teams/#{team!}/posts/#{post_id}/good_jobs", params: params)
    end

    def delete_good_job(post_id, good_job_id)
      request(method: :delete, path: "/teams/#{team!}/posts/#{post_id}/good_jobs/#{good_job_id}")
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
      request(method: :get, path: "/teams/#{team!}/attachments/#{id}", for_binary: true)
    end

    private

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
        'Accept'         => 'application/json',
        'User-Agent'     => USER_AGENT,
        'X-DocBaseToken' => access_token,
      }
    end

    def request(method:, path:, params: nil, for_binary: false)
      conn = for_binary ? connection_for_binary : connection
      response = conn.send(method, path, params)
      raise TooManyRequestError if retry_on_rate_limit_exceeded && response.status == 429
      response
    rescue TooManyRequestError
      reset_time = response.headers['x-ratelimit-reset'].to_i
      puts "DocBase API Rate limit exceeded: will retry at #{Time.at(reset_time).strftime("%Y/%m/%d %H:%M:%S")}."
      wait_for(reset_time)
      retry
    end

    def wait_for(reset_time)
      wait_time = reset_time - Time.now.to_i
      return if wait_time <= 0
      sleep wait_time
    end
  end
end
