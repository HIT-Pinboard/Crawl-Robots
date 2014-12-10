#!/usr/bin/env ruby 
#encoding: utf-8
require 'sinatra'
require 'json'
require './MysqlConn.rb'

set :port, 8080
set :environment, :production

get '/' do
	"Hello RESTFul!"
end


#generating tree structure, not good enough,especially when the amount of tags are huge
#need to be altered!!!
get '/tagsList' do
	content_type :json
	#connect to Mysql and get all the tags as a list
	puts "ask for tagsArray!"
	mysql_conn=MysqlConn.new
	tagsList = mysql_conn.getTagsList # 
	i=0
	tagsArray = []
	tagsList.each_hash { |h|

		node = {
			"name"=>h["DeptChn"].force_encoding("UTF-8"),    #Chinese string
			"value"=>h["DeptNum"].to_s,
			"children"=>[
				{
					"name"=>h["DeptChn"].force_encoding("UTF-8")+' - '+"新闻",   #Chinese  string
					"value"=>h["DeptNum"].to_s+".1",
					"children"=>[]
					},
				{
					"name"=>h["DeptChn"].force_encoding("UTF-8")+' - '+"公告",
					"value"=>h["DeptNum"].to_s+".2",
					"children"=>[]	
					}]
		}
		tagsArray[i,0] = [node]
        i+=1
	}
	mysql_conn.close
	return_message = {
		"status" => 200,
		"response" => tagsArray
	}
	return_message.to_json
end

post '/newsList' do
	content_type :json
	puts params# debug in console
	newsList=[]
	data = params["data"]
	start_index =  data["start_index"].to_i  #get params from jason   ????start_index or +1
	count = data["count"].to_i
	puts "ask for newsList! start_index is #{start_index},count is #{count}"
	if data.has_key?("tags")
		tags = data["tags"]
		if tags[0] == "0"
			mysql_conn=MysqlConn.new
		    newsList=mysql_conn.getNewsListAll(start_index,count)    #no  tag p and c;  
        else
			#connect to Mysql and get the news needed according to tags,start_index and count
			mysql_conn=MysqlConn.new
			newsList=mysql_conn.getNewsList(tags,start_index,count)    #no  tag p and c;
		end
		i=0
		newsArray = []
		newsList.each_hash { |h|
			node = {
				"title" => h["Title"].force_encoding("UTF-8"),
				"link" => '/'+h["JSONFilePath"],   #
				"tags" => [h["Tag"]],
				"date" => h["Time"]
			}
			puts node["date"]
			puts node["tags"]
			newsArray[i,0] = [node]
	        i+=1
		}
		mysql_conn.close
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
	puts "get the json file"
	filePath=params[:splat][0]+'/'+params[:splat][1]+'.json'
	file = File.read(filePath, :encoding => 'UTF-8')
	data_hash = JSON.parse(file)
	return_message={
		"status"=>200,
		"response"=>{
			"title"=>data_hash["title"],
			"url"=>data_hash["link"],
			"date"=>data_hash["date"],
			"tags"=>data_hash["tags"],
			"content"=>data_hash["content"],
			"imgs"=>data_hash["imgs"]
		}
	}
	return_message.to_json
end

post '/push' do
	token = params["token"]
	action = params["action"]
	tags = params["tags"]
	mysql_conn = PBDBConn.new
	case action
	when "register"
		#insert
		mysql_conn.removeID(token)
		mysql_conn.updateID(token,tags)
	else "remove"
		#delete
		mysql_conn.removeID(token)
	end
	conn.close
end
	





