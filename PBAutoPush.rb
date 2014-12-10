require 'mysql'
require 'houston'
require './PBTAO.rb'

mysql_conn = PBDBConn.new
tao = PBTAO.new
users = mysql_conn.getUsersList
last_update_path = "./last_update.json"
last_update = JSON.parse(open(last_update_path).read)
users.each_hash { |h|
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
	#houston push pushString to UserID
	if pushFlag == true
		APN = Houston::Client.development
		APN.certificate = File.read("/path/to/apple_push_notification.pem")
		notification = Houston::Notification.new(device: UserID)
		notification.alert = pushString
		notification.badge = count
		APN.push(notification)
	end

}
