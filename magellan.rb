########################################
#  Magellan: Vending Machine Explorer  #
#  v1.0 Clayton Walker                 #
########################################

require 'sinatra'
require 'dbi'
require 'erb'
require 'logger'
require_relative './location'
require_relative './venddb'


$log = Logger.new('./logs/magellan.log')


#sinatra config
ENV['RACK_ENV'] = 'production'
set :port, '80'
set :bind, '0.0.0.0'
set :server, 'thin'
set :environment, ENV['RACK_ENV']
enable :logging
	
get '/' do
		redirect '/magellan'
end


get '/magellan/?' do
	$log.info 'Form displayed: ' + request.env['REMOTE_ADDR']
	erb :magellan
end

post '/magellan/?' do
	
	user_loc = Location.new('F' + params[:floor] + params[:location])
	m = MachineFinder.new(user_loc,params[:drink],params[:payment])
	$log.info request.env['REMOTE_ADDR'] + user_loc.inspect + ' D:' + params[:drink] + ' P:' + params[:payment] + ' '  + m.inspect
	erb :results, :locals => {:m => m, :user_loc => user_loc}
end

get '/magellan/machine/:machine' do
		begin
			m = Machine.find(params[:machine])
			$log.info request.env['REMOTE_ADDR'] + ' ' + m.inspect
			erb :machine, :locals => {:machine => m}
		rescue ActiveRecord::RecordNotFound
			$log.warn request.env['REMOTE_ADDR'] + ' Machine not found: ' + params[:machine]
			redirect '/magellan' 
		end
end

post '/magellan/machine/:machine' do
	c= Comment.create(machine_id: params[:machine], comment: params[:comment])
	$log.info request.env['REMOTE_ADDR'] + ' ' + c.inspect
	redirect '/magellan/machine/' + params[:machine]
end




	
