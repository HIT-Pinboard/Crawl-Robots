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
			@apn = Houston::Client.development
		else
			raise "[FATAL]: config file not found"
		end
	end

	def push(uuid, badge, string)
		@apn.certificate = File.read("/Users/Yifei/Developer/push_cert.pem")
		notification = Houston::Notification.new(device: uuid)
		notification.alert = string
		notification.badge = badge
		@apn.push(notification)
	end

	def check_update
		users = @conn.getUsersList
		users.each_hash do |h|
			uuid = h["UUID"]
			user_tags = []
			h["UserTags"].split(',').each do |tag|
				user_tags += @tao.query(tag)
			end
			user_tags = user_tags.uniq
			shouldSendPush = false
			content = ""
			count = 0
			user_tags.each do |i|
		        if @last_update[i]["count"] > 0
		        	shouldSendPush = true
		        	count += @last_update[i]["count"]
		        	content += @tao.full_name(i) + "更新了" + @last_update[i]["count"].to_s + "条内容，"
				end
			end
			content += '点击这里阅读。'
			if content.length > 30
				content = '您订阅的多个网站有更新了，点击这里阅读。'
			end
			if shouldSendPush
				push(uuid, count, content)
			end
		end
		@conn.close
	end

end