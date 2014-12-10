require 'mysql'
require 'houston'

mysql_conn = PBDBConn.new
user = mysql_conn.getUserTags
last_update_path = "./last_update.json"
last_update = JSON.parse(open(last_update_path).read)
user.each_hash { |h|
	UserID = h["UserID"]
	UserTags = h["UserT-ags"].split(' ')
	pushFlag = false
	pushString = ""
	count = 0
	0.upto(UserTags.length-1){ |i|
		# better to have a update bit
        if last_update[UserTags[i]]["count"]>0
        	pushFlag = true
        	count = count + last_update[UserTags[i]]["count"]
        	#pushString in Chinese
        	pushString = pushString + "#{UserTags[i]}" + "gengxinle" + last_update[UserTags[i]]["count"].to_s + "tiao "
	}
	#houston push pushString to UserID
	if pushFlag == true
		APN = Houston::Client.development
		APN.certificate = File.read("/path/to/apple_push_notification.pem")
		notification = Houston::Notification.new(device: UserID)
		notification.alert = pushString
		notification.badge = 
		APN.push(notification)
	end

}
