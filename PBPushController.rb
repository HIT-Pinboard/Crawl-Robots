require 'mysql'
require 'open-uri'
require 'houston'
require './PBTAO.rb'
require './PBDBConnector.rb'

class PBPushController

	def initialize(conf_filepath = './last_update.json')
		@conf_filepath = conf_filepath
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

	def check_update(latest_tag_id)
		return if !latest_tag_id

		if !@last_update.has_key?'latest_tag_id'
			last_tag_id = 0
		else
			last_tag_id = @last_update['latest_tag_id']
		end
		users = @conn.getUsersList
		users.each_hash do |h|
			uuid = h["UUID"]
			user_tags = []
			h["Tags"].split(',').each do |tag|
				user_tags += @tao.query(tag)
			end
			user_tags = user_tags.uniq
			updated_tags = []
			
			# which tag has update
			user_tags.each do |i|
		        updated_tags << @tao.full_name(i) if @conn.getTagsCount([i], last_tag_id) > 0
			end

			# get all count
			if (count = @conn.getTagsCount(user_tags, last_tag_id)) > 0
				content = "订阅的#{updated_tags.join('、')}有#{count}条更新，点击这里阅读。"
				content = "订阅的多个关键词有#{count}条更新，点击这里阅读。" if content.length > 30
			end

			push(uuid, count, content) if count > 0

		end
		@conn.close

		
		@last_update['latest_tag_id'] = latest_tag_id
		File.open(@conf_filepath, 'w') { |file|
			string = JSON.pretty_generate(@last_update)
			file.write(string)
		}
		
	end

end