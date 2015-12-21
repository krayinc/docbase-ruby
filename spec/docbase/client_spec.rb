require 'spec_helper'

describe DocBase::Client do
  let(:access_token) { 'ab32vadvxG' }
  let(:client) { DocBase::Client.new(access_token: access_token, team: 'kray') }

  describe '#headers' do
    let(:headers) do
      {
        'Accept'         => 'application/json',
        'User-Agent'     => DocBase::Client::USER_AGENT,
        'X-DocBaseToken' => access_token,
      }
    end

    it 'set headers' do
      expect(client.headers).to eq(headers)
    end
  end

  describe '#team!' do
    context 'not set team' do
      before { client.team = nil }

      it 'raise error' do
        expect { client.team! }.to raise_error(DocBase::Client::NotSetTeamError)
      end
    end
  end

  shared_examples 'stub connection' do |arg|
    let(:connection) do
      Faraday.new do |c|
        c.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
          stub.send(arg[:method], path) { [200, {}, body] }
        end
      end
    end

    before do
      allow(client).to receive(:connection).and_return(connection)
    end

    subject { response_body }
    it { should eq(response_body) }
  end

  describe '#teams' do
    let(:path) { '/teams' }
    let(:body) do
      [
       { domain: 'kray', name: 'kray' },
       { domain: 'danny', name: 'danny' },
      ]
    end

    let(:response_body) { client.teams.body }

    it_behaves_like 'stub connection', { method: :get }
  end

  describe '#tags' do
    let(:path) { "/teams/#{client.team}/tags" }
    let(:body) do
      [
        { name: 'ruby' },
        { name: 'rails' },
      ]
    end
    let(:response_body) { client.tags.body }

    it_behaves_like 'stub connection', { method: :get }
  end

  describe '#groups' do
    let(:path) { "/teams/#{client.team}/groups" }
    let(:body) do
      [
        { id: 1, name: 'DocBase' },
        { id: 2, name: 'kray' },
      ]
    end
    let(:response_body) { client.groups.body }

    it_behaves_like 'stub connection', { method: :get }
  end

  describe '#posts' do
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
    let(:response_body) { client.posts(params).body }

    it_behaves_like 'stub connection', { method: :post }
  end
end
