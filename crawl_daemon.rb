require './PBGeneralFetcher.rb'
require './CSAnnoFetcher.rb'
require './CSNewsFetcher.rb'
require './SSFetcher.rb'
require './TodayFetcher.rb'
require './PBPushController.rb'
require 'open-uri'
require 'time'

interval = 3600

start_hour = 8
end_hour = 22

config_array = ["./sme.hit.edu.cn.json","./sa.hit.edu.cn.json","./power.hit.edu.cn.json",
			"./jwc.hit.edu.cn.json","./ssc.hit.edu.cn.json","./rwxy.hit.edu.cn.json","./jtxy.hit.edu.cn.json",
			"./mse.hit.edu.cn.json","./chemeng.hit.edu.cn.json","./cwc.hit.edu.cn.json"]

while true

	if Time.now.hour.between?(start_hour, end_hour)

		latest_tag_id = nil


		config_array.each do |conf|
			# begin
				fetcher = PBGeneralFetcher.new(conf)
				if rs = fetcher.fetch
					latest_tag_id = rs
				end
			# rescue Exception => e
			# 	puts "[ERROR]: Fetcher crashed at #{e.backtrace}"
			# 	# to-do: add mail notification support
			# end
		end

		fetcher = CSAnnoFetcher.new("./cs.hit.edu.cn_anno.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = CSNewsFetcher.new("./cs.hit.edu.cn_news.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = SSFetcher.new("./software.hit.edu.cn.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

    fetcher = TodayFetcher.new("./today.hit.edu.cn.json")
    if rs = fetcher.fetch
      latest_tag_id = rs
    end

		pushController = PBPushController.new
		pushController.check_update(latest_tag_id)

	end
	puts "[INFO]: main thread go to sleep #{interval}"
	sleep(interval)
end
