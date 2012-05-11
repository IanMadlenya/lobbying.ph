$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'sinatra'
require 'compass'
require 'sass'
require 'data_mapper'
require 'json'

require 'models/lobbyist'
require 'models/firm'
require 'models/principal'

# setup db
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/lobbying.db")
DataMapper.finalize
Lobbyist.auto_upgrade!
Firm.auto_upgrade!
Principal.auto_upgrade!

get '/' do
  @all_lobbyists = Lobbyist.all()
  @firms = Firm.all()
  @principals = Principal.all()
  @lobbyists = Lobbyist.all(:order => [ :id.desc ], :limit => 20)

  if params[:search]
    @lobbyists = Lobbyist.search(params[:search])
  end

  erb :index
end

get '/list/firms' do
	@lobbyists = Lobbyist.all()
  @firms = Firm.all()
  @principals = Principal.all()
	@data = Firm.all()
	@title = "Registered Philadelphia Lobbying Firms"

	erb :list
end

get '/list/principals' do
	@lobbyists = Lobbyist.all()
  @firms = Firm.all()
  @principals = Principal.all()
	@data = Principal.all()
	@title = "Principals"

	erb :list
end

get '/list/lobbyists' do
	@lobbyists = Lobbyist.all()
  @firms = Firm.all()
  @principals = Principal.all()
	@data = Lobbyist.all()
	@title = "Registered Philadelphia Lobbyists"

	erb :list
end

get '/stylesheets/:name.css' do
  scss(:"stylesheets/#{params[:name]}")
end

get '/graphdata' do
  @lobbyists = Lobbyist.all()

  if (params[:search])
    @lobbyists = Lobbyist.search(params[:search])
  end

  @lobbyists = @lobbyists.map do |lobbyist|
    l = {:id => "lobbyist_"+ lobbyist.id.to_s, :type => "lobbyist", :name => lobbyist.name, :firm_id => "firm_#{lobbyist.firm_id}"}
    if (lobbyist.firm_id != nil)
      l[:firmname] = Firm.get(lobbyist.firm_id).name
    end
    l
  end

  @firms = Firm.all()

  if (params[:search])
    @firms = Firm.search(params[:search])
  end

  @firms = @firms.map do |firm|
     l = {:id => "firm_"+ firm.id.to_s, :type => "firm", :name => firm.name}
   end
  @nodes = @lobbyists + @firms

  @graphdata = true
  erb :graphdata
end

get '/graphdata.json' do
  content_type :json
  @lobbyists = Lobbyist.all()
  @lobbyists.to_json
end

get '/results' do

  @lobbyists = Lobbyist.search(params[:search])
  @firms = Firm.search(params[:search])
  @principals = Principal.search(params[:search])

  erb :results
end

get '/lobbyist/:id' do
	@data = Lobbyist.get(params[:id])
	erb :detail
end

get '/firm/:id' do
	@data = Firm.get(params[:id])
	erb :detail
end

get '/principal/:id' do
	@data = Principal.get(params[:id])
	erb :detail
end

get '/about' do
	erb :about
end

# Helpers
helpers do
  def link_to(url, text=url, opts={})
    attributes = ""
    opts.each { |key, value| attributes << key.to_s << "=\"" << value << "\" "}
    "<a href=\"#{url}\" #{attributes}>#{text}</a>"
  end

  def current_class(path="")
    request.path_info == "/#{path}" ? "current": nil
  end

  def address_string(lobbyist)
    addr_str = ""
    if lobbyist.address1
      addr_str += "#{lobbyist.address1}"
    end
    if lobbyist.address2
      addr_str += ", #{lobbyist.address2}"
    end
    if lobbyist.address3
      addr_str += ", #{lobbyist.address3}"
    end
    if lobbyist.city
      addr_str += ", #{lobbyist.city}"
    end
    if lobbyist.state && lobbyist.zip
      addr_str += ", #{lobbyist.state}, #{lobbyist.zip}"
    end

    addr_str
  end
  
end
