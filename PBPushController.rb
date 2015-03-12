require 'mysql'
require 'open-uri'
require 'houston'
require 'json'
require 'PBRobot'
require './PBTAO.rb'
require './PBDBConnector.rb'

class PBPushController

	def initialize(last_update_filepath = './last_update.json', certs_filepath = './certs.json', options = {})
		@last_update_filepath = last_update_filepath

		@last_update = PBRobot::Helper::json_with_filepath(last_update_filepath)
		@certs = PBRobot::Helper::json_with_filepath(certs_filepath)
		@tao = PBTAO.new
		@conn = PBDBConn.new
		@apn = options[:debug] ? Houston::Client.development : Houston::Client.production
	end

	def push(uuid, badge, string)

		case @apn.gateway_uri
		when "apn://gateway.sandbox.push.apple.com:2195"
			# development
			@apn.certificate = @certs["dev_cert"]
		when "apn://gateway.push.apple.com:2195"
			# production
			@apn.certificate = @certs["pro_cert"]
		end

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
		PBRobot::Helper::write_to_json(@last_update_filepath, @last_update)
		
	end

end