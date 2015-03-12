require './PBGeneralFetcher.rb'
require './CSAnnoFetcher.rb'
require './CSNewsFetcher.rb'
require './SSFetcher.rb'
require './TodayFetcher.rb'
require './PBPushController.rb'
require './PBDBConnector.rb'
require './PBNewsObject.rb'
require 'open-uri'
require 'time'
# mail is optional
begin
	require 'mail'
rescue LoadError
	DO_NOT_SENDMAIL = 1
else
	MAIL_FROM = ''
	MAIL_TO = ''
end

interval = 3600

start_hour = 8
end_hour = 22

config_array = ["./sme.hit.edu.cn.json","./sa.hit.edu.cn.json","./power.hit.edu.cn.json",
			"./jwc.hit.edu.cn.json","./ssc.hit.edu.cn.json","./rwxy.hit.edu.cn.json","./jtxy.hit.edu.cn.json",
			"./mse.hit.edu.cn.json","./chemeng.hit.edu.cn.json","./cwc.hit.edu.cn.json"]

def invoke_fetcher(&block)
	# block should return a fetcher
	begin
		fetcher = block.call
		if fetcher.is_a?(PBRobot::Fetcher) && 
			rs = fetcher.fetch { |obj, base| PBNewsObject.new(obj, base).save(conn) }
			@latest_tag_id = rs
		end
	rescue Exception => e
		puts "[ERROR]: #{fetcher.class} crashed at #{e.backtrace}"
		if !DO_NOT_SENDMAIL
			err_msg = "#{e.inspect}\n\n#{e.backtrace}"
			Mail.deliver do 
				from		MAIL_FROM
				to 			MAIL_TO
				subject "Fetcher #{fetcher.class} crashed at #{Time.now}"
				body		err_msg
			end
		end
	end
end

while true

	if Time.now.hour.between?(start_hour, end_hour)

		@latest_tag_id = nil

		conn = PBDBConn.new

		config_array.each do |conf|
			invoke_fetcher { PBGeneralFetcher.new(conf) }
		end

		invoke_fetcher { CSAnnoFetcher.new("./cs.hit.edu.cn_anno.json") }

		invoke_fetcher { CSNewsFetcher.new("./cs.hit.edu.cn_news.json") }

		invoke_fetcher { SSFetcher.new("./software.hit.edu.cn.json") }

		invoke_fetcher { TodayFetcher.new("./today.hit.edu.cn.json") }

		conn.close

		pushController = PBPushController.new
		pushController.check_update(@latest_tag_id)

	end
	puts "[INFO]: main thread go to sleep #{interval}"
	sleep(interval)
end
