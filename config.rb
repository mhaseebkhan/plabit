require 'plaid'
require 'clearbit'

Plaid.config do |p|
  p.client_id = ENV['PLAID_CLIENT_ID']
  p.secret = ENV['PLAID_SECRET']
  p.env = :tartan
end

Clearbit.key = ENV['CLEARBIT_KEY']

get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

