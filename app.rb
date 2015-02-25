require 'sinatra'
require 'rest-client'
require 'uri-handler'

configure do
    set :protection, except: [:frame_options]
end

get '/' do
  erb :index
end

post '/install' do
  name = "Orderdesk".to_uri
  url = "https://#{request.host}/iframe/#{params[:store_id]}/#{params[:api_key]}".to_uri
  description = "Show orders from Orderdesk in Firma".to_uri
  icon = "http://www.orderdesk.me/wp-content/themes/orderdesk/images/logo.png".to_uri

  if Sinatra::Base.development?
    server = "http://localhost:3000"
  else
    server = "https://app.firmafon.dk"
  end

  redirect to("#{server}/integrations/new?provider=external_app&name=#{name}&url=#{url}&description=#{description}&icon=#{icon}")
end

get '/iframe/:store_id/:api_key' do

  api_url = "https://app.orderdesk.me/api/orders"

  num = params[:number][2..-1].to_uri

  raw = RestClient.get api_url, :params => {:customer_phone => num, :limit => 10}, :content_type => 'application/json', :'ORDERDESK-STORE-ID' => params[:store_id], :'ORDERDESK-API-KEY' => params[:api_key]

  @orders = JSON.parse(raw)

  erb :iframe

end
