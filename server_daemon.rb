#!/usr/bin/env ruby 
#encoding: utf-8
require 'sinatra'
require 'json'
require './PBDBConnector.rb'

set :port, 8080
set :environment, :production

get '/' do
	"Hello RESTFul!"
end


get '/tagsList' do
	content_type :json
	filepath = "./tagsList.json"
	tagsList = JSON.parse(open(filepath).read)["data"]
	return_message = {
		"status" => 200,
		"response" => tagsList
	}
	return_message.to_json
end

post '/newsList' do
	content_type :json
	data = params["data"]
	start_index =  data["start_index"].to_i
	count = data["count"].to_i
	if data.has_key?("tags")
		tags = data["tags"]
		conn = PBDBConn.new
		if tags.first == "0"
		    newsList = conn.getNewsListAll(start_index, count)    #no  tag p and c;  
        else
			newsList = conn.getNewsList(tags,start_index,count)    #no  tag p and c;
		end
		i = 0
		newsArray = []
		newsList.each_hash { |h|
			node = {
				"title" => h["Title"].force_encoding('UTF-8'),
				"link" => h["Filepath"],
				"tags" => [h["Tag"]],
				"date" => h["Date"]
			}
			newsArray[i, 0] = [node]
	        i += 1
		}
		conn.close
		return_message = {
			"status" => 200,
			"response" => newsArray
		}
	else
		return_message = {
			"status" => 200,
			"response" => []
		}
	end
	return_message.to_json
end

get '/*/*.json' do
	content_type :json
	filePath = params[:splat][0]+'/'+params[:splat][1]+'.json'
	file = File.read(filePath, :encoding => 'UTF-8')
	data_hash = JSON.parse(file)
	return_message = {
		"status" => 200,
		"response" => data_hash
	}
	return_message.to_json
end

post '/push' do
	data = params["data"]
	token = data["token"]
	action = data["action"]
	tags = data["tags"]
	conn = PBDBConn.new
	case action
	when "register"
		conn.removeID(token)
		conn.updateID(token,tags)
	when "remove"
		conn.removeID(token)
	end
	conn.close
end
	





