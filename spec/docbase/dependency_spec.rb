require 'spec_helper'

describe 'docbase.gemspec' do
  let(:spec) { Gem::Specification.load(File.expand_path('../../docbase.gemspec', __dir__)) }
  let(:faraday) { spec.runtime_dependencies.find { |d| d.name == 'faraday' } }

  it 'does not depend on faraday_middleware' do
    expect(spec.runtime_dependencies.map(&:name)).not_to include('faraday_middleware')
  end

  it 'rejects faraday versions with known vulnerabilities' do
    %w[0.17.6 1.10.5].each { |v| expect(faraday.match?('faraday', v)).to be false }
  end

  it 'accepts patched faraday 1.x and 2.x' do
    %w[1.10.6 2.15.1].each { |v| expect(faraday.match?('faraday', v)).to be true }
  end
end

describe DocBase::Client do
  it 'encodes requests and parses responses as JSON with faraday built-in middleware' do
    handlers = DocBase::Client.new(access_token: 't', team: 'kray').send(:connection).builder.handlers
    expect(handlers).to eq [Faraday::Request::Json, Faraday::Response::Json]
  end
end
