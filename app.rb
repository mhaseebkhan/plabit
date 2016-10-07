require "bundler/setup"
require "sinatra"
require "rack/csrf"
require 'plaid'
require 'clearbit'
require 'json'
require 'uri'
require 'open-uri'

Dir.glob(File.join("helpers", "**", "*.rb")).each do |helper|
  require_relative helper
end

require "sinatra/reloader" if development?

# use Rack::Session::Cookie, :secret => "TODO: CHANGE ME"
# use Rack::Csrf, :raise => true

Plaid.config do |p|
  p.client_id = ENV['PLAID_CLIENT_ID']
  p.secret = ENV['PLAID_SECRET']
  p.env = :tartan
end

Clearbit.key = ENV['CLEARBIT_KEY']

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

# AJAX endpoint that first exchanges a public_token from the Plaid Link
# module for a Plaid access token. That access_token is then used to
# retrieve account and balance data for a user using plaid-ruby.
get '/accounts' do
  # Pull the public_token from the querystring
  public_token = params[:public_token]

  # Exchange the Link public_token for a Plaid API access token
  exchange_token_response = Plaid::User.exchange_token(public_token)

  # Initialize a Plaid user
  user = Plaid::User.load(:auth, exchange_token_response.access_token)

  # Retrieve information about the user's accounts
  user.auth

  # Transform each account object to a simple hash
  transformed_accounts = user.accounts.map do |account|
    {
        balance: {
            available: account.available_balance,
            current: account.current_balance
        },
        meta: account.meta,
        type: account.type
    }
  end

  # Return the account data as a JSON response
  content_type :json
  { accounts: transformed_accounts }.to_json
end

get '/transactions' do
  if params[:public_token]
    public_token = params[:public_token]

    # Exchange the Link public_token for a Plaid API access token
    exchange_token_response = Plaid::User.exchange_token(public_token)

    # Initialize a Plaid user
    user = Plaid::User.load(:auth, exchange_token_response.access_token)

    # Retrieve information about the user's accounts
    user.auth
  end
  @companies = []
  user ||= Plaid::User.create(:connect, 'wells', 'plaid_test', 'plaid_good')
  @transactions = user.transactions
  erb :index
end

get '/companies' do
  transaction = params[:name]
  result = Clearbit::Discovery.search(
      query: {name: transaction},
      sort: 'alexa_asc'
  )

  if !(result['results'].empty?)
    domain = result['results'][0]['domain']
    company = Clearbit::Enrichment::Company.find(domain: domain, stream: true)
    company = company.select {|k,v| ["name","domain","address","category","logo","phone"].include?(k) }
  else
    company = "Unable to extract company Info"
  end
  content_type :json

  { company: company }.to_json
end
