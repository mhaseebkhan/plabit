ENV["RACK_ENV"] = "test"

require "test/unit"
require "contest"
require "rack/test"
require "dotenv"
require "vcr"
require_relative "../../app"

Dotenv.load

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end


before do

  Plaid.config do |p|
    p.client_id = ENV['PLAID_CLIENT_ID']
    p.secret = ENV['PLAID_SECRET']
    p.env = :tartan
  end

  Clearbit.key = ENV['CLEARBIT_KEY']
end

class TransactionTest < Test::Unit::TestCase
  include Rack::Test::Methods


  def app
    Sinatra::Application
  end

  def test_home
    get '/'
    assert last_response.ok?
  end

  def test_transactions
    VCR.use_cassette("transactions") do
      get '/transactions'
      assert last_response.ok?
    end
  end

end
