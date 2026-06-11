require 'spec_helper'

describe DocBase::Client do
  let(:access_token) { 'ab32vadvxG' }
  let(:client) { DocBase::Client.new(access_token: access_token, team: 'kray') }
  let(:http_status_code) { 200 }
  let(:http_headers) { {} }
  let(:connection) do
    Faraday.new do |c|
      c.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.send(method, path) { [http_status_code, http_headers, body] }
      end
    end
  end

  before { allow(client).to receive(:connection).and_return(connection) }


  describe '#team!' do
    context 'not set team' do
      before { client.team = nil }

      it 'raise error' do
        expect { client.team! }.to raise_error(DocBase::Client::NotSetTeamError)
      end
    end
  end

  shared_examples 'stub connection' do |arg|
    subject { response_body }
    it { should eq(response_body) }
  end

  describe '#tags' do
    let(:path) { "/teams/#{client.team}/tags" }
    let(:body) do
      [
        { name: 'ruby' },
        { name: 'rails' },
      ]
    end
    let(:method) { :get }
    let(:response_body) { client.tags.body }

    it_behaves_like 'stub connection'
  end

  describe '#groups' do
    let(:path) { "/teams/#{client.team}/groups" }
    let(:body) do
      [
        { id: 1, name: 'DocBase' },
        { id: 2, name: 'kray' },
      ]
    end
    let(:method) { :get }
    let(:response_body) { client.groups.body }

    it_behaves_like 'stub connection'
  end

  describe '#profile' do
    let(:path) { "/teams/#{client.team}/profile" }
    let(:body) do
      {
        id: 1,
        name: 'docbaseman',
        username: 'docbaseman',
      }
    end
    let(:method) { :get }
    let(:response_body) { client.profile.body }

    it_behaves_like 'stub connection'
  end

  describe '#user_groups' do
    let(:path) { "/teams/#{client.team}/users/1/groups" }
    let(:body) do
      [
        { id: 1, name: 'グループ1' },
      ]
    end
    let(:method) { :get }
    let(:response_body) { client.user_groups(1).body }

    it_behaves_like 'stub connection'
  end

  describe '#comments' do
    let(:path) { "/teams/#{client.team}/posts/1/comments" }
    let(:body) do
      {
        comments: [
          {
            id: 1,
            post_id: 1,
            body: 'comment',
          },
        ],
        meta: {
          total: 1,
        },
      }
    end
    let(:method) { :get }
    let(:response_body) { client.comments(1).body }

    it_behaves_like 'stub connection'
  end

  describe '#good_jobs' do
    let(:path) { "/teams/#{client.team}/posts/1/good_jobs" }
    let(:body) do
      {
        good_jobs: [
          {
            id: 1,
            post_id: 1,
            user_id: 1,
          },
        ],
        meta: {
          total: 1,
        },
      }
    end
    let(:method) { :get }
    let(:response_body) { client.good_jobs(1).body }

    it_behaves_like 'stub connection'
  end

  describe '#create_good_job' do
    let(:path) { "/teams/#{client.team}/posts/1/good_jobs" }
    let(:body) do
      {
        id: 1,
        post_id: 1,
        user_id: 1,
        created_at: '2015-03-10T12:01:54+09:00',
      }
    end
    let(:method) { :post }
    let(:response_body) { client.create_good_job(1, notice: true).body }

    it_behaves_like 'stub connection'
  end

  describe '#delete_good_job' do
    let(:path) { "/teams/#{client.team}/posts/1/good_jobs/111" }
    let(:body) { nil }
    let(:method) { :delete }
    let(:response_body) { client.delete_good_job(1, 111).body }

    it_behaves_like 'stub connection'
  end

  describe '#delete_user' do
    let(:path) { "/teams/#{client.team}/users/1" }
    let(:body) { nil }
    let(:method) { :delete }
    let(:response_body) { client.delete_user(1).body }

    it_behaves_like 'stub connection'
  end

  describe '#create_post' do
    let(:path) { "/teams/#{client.team}/posts" }
    let(:params) do
      {
        title: 'memo title',
        body: 'memo body',
        draft: false,
        tags: ['rails', 'ruby'],
        scope: 'group',
        groups: [1],
        notice: true,
      }
    end
    let(:body) do
      {
        id: 1,
        title: 'memo title',
        body: 'memo body',
        draft: false,
        url: 'https://kray.docbase.io/posts/1',
        created_at: '2015-03-10T12:01:54+09:00',
        tags: [
          { name: 'rails' },
          { name: 'ruby' },
        ],
        scope: 'group',
        groups: [
          { name: 'DocBase' }
        ],
        user: {
          id: 1,
          name: 'danny'
        },
      }
    end
    let(:method) { :post }
    let(:response_body) { client.create_post(params).body }

    it_behaves_like 'stub connection'
  end

  describe '#update_post_body' do
    let(:path) { "/teams/#{client.team}/posts/1/body" }
    let(:params) do
      {
        id: 1,
        operations: [
          {
            start: 1,
            end: 1,
            old_content: 'old',
            content: 'new',
          },
        ],
      }
    end
    let(:body) do
      {
        id: 1,
        title: 'memo title',
        body: 'new',
      }
    end
    let(:method) { :patch }
    let(:response_body) { client.update_post_body(params).body }

    it_behaves_like 'stub connection'
  end

  describe '#create_comment' do
    it 'sends comment params without post_id' do
      expect(client).to receive(:request).with(
        method: :post,
        path: "/teams/#{client.team}/posts/1/comments",
        params: { body: 'GJ!!', notice: true }
      ).and_return(double(body: {}))

      client.create_comment(post_id: 1, body: 'GJ!!', notice: true)
    end
  end

  describe '#update_post' do
    context 'when id is missing' do
      it 'raises NotSetPostIdError' do
        expect { client.update_post(title: 'title') }.to raise_error(DocBase::Client::NotSetPostIdError)
      end
    end
  end

  describe '#request' do
    context 'API rate limit exceeded' do
      before { allow(Time).to receive_message_chain(:now).and_return(Time.now) }
      before { allow(client).to receive(:connection).and_return(connection, retry_connection) }
      let(:retry_connection) do
        Faraday.new do |c|
          c.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
            stub.send(method, path) { [200, {}, retry_connection_body] }
          end
        end
      end
      let!(:client) { DocBase::Client.new(access_token: access_token, team: 'kray', retry_on_rate_limit_exceeded: true) }
      let!(:http_status_code) { 429 }
      let!(:http_headers) { { 'x-ratelimit-reset': (Time.now + 1).to_i } }
      let(:path) { "/teams/#{client.team}/tags" }
      let(:body) { { "error"=>"too_many_requests", "messages"=>["Too Many Requests"] } }
      let(:retry_connection_body) do
        [
          { name: 'ruby' },
          { name: 'rails' },
        ]
      end
      let(:method) { :get }
      let(:response_body) { client.tags.body }

      it 'successful retry' do
        expect(response_body).to eq(retry_connection_body)
      end
    end
  end
end
