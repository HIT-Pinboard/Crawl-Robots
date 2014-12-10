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

	def push(uuid, badge, string)
		APN = Houston::Client.development
		APN.certificate = File.read("/path/to/apple_push_notification.pem")
		notification = Houston::Notification.new(device: uuid)
		notification.alert = string
		notification.badge = badge
		APN.push(notification)
	end

	def check_update
		users = @conn.getUsersList
		users.each_hash do |h|
			uuid = h["UUID"]
			UserTags = h["UserTags"].split(',')
			shouldSendPush = false
			content = ""
			count = 0
			UserTags.each do |i|
				# better to have a update bit
		        if last_update[UserTags[i]]["count"] > 0
		        	shouldSendPush = true
		        	count += last_update[UserTags[i]]["count"]
		        	content += tao.full_name(i) + "更新了" + last_update[UserTags[i]]["count"].to_s + "条内容，"
				end
			end
			content += '点击这里阅读。'
			if shouldSendPush
				push(uuid, count, content)
			end
		end
		@conn.close
	end

end