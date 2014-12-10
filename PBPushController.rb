require 'mysql'
require 'open-uri'
require 'houston'
require './PBTAO.rb'
require './PBDBConnector.rb'

class PBPushController

	def initialize(conf_filepath = './last_update.json')
		if File.exist?conf_filepath
			@last_update = JSON.parse(open(conf_filepath).read)
			@tao = PBTAO.new
			@conn = PBDBConn.new
		else
			raise "[FATAL]: config file not found"
		end
	end

	def push(userID, badge, string)
		APN = Houston::Client.development
		APN.certificate = File.read("/path/to/apple_push_notification.pem")
		notification = Houston::Notification.new(device: userID)
		notification.alert = string
		notification.badge = badge
		APN.push(notification)
	end

	def check_update
		users = @conn.getUsersList
		users.each_hash do |h|
			UserID = h["UserID"]
			UserTags = h["UserTags"].split(',')
			pushFlag = false
			pushString = ""
			count = 0
			UserTags.each do |i|
				# better to have a update bit
		        if last_update[UserTags[i]]["count"] > 0
		        	pushFlag = true
		        	count += last_update[UserTags[i]]["count"]
		        	#pushString in Chinese, change to tao access method
		        	pushString = pushString + "#{UserTags[i]}" + "gengxinle" + last_update[UserTags[i]]["count"].to_s + "tiao "
				end
			end
			if pushFlag
				push(UserID, count, pushString)
			end
		end
	end

end