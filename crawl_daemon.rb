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

while true

	if Time.now.hour.between?(start_hour, end_hour)

		latest_tag_id = nil

		fetcher = PBGeneralFetcher.new("./sme.hit.edu.cn.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = PBGeneralFetcher.new("./sa.hit.edu.cn.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = PBGeneralFetcher.new("./power.hit.edu.cn.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = PBGeneralFetcher.new("./jwc.hit.edu.cn.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = PBGeneralFetcher.new("./ssc.hit.edu.cn.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = PBGeneralFetcher.new("./rwxy.hit.edu.cn.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = PBGeneralFetcher.new("./jtxy.hit.edu.cn.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = PBGeneralFetcher.new("./chemeng.hit.edu.cn.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = CSAnnoFetcher.new("./cs.hit.edu.cn_anno.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = CSNewsFetcher.new("./cs.hit.edu.cn_news.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = PBGeneralFetcher.new("./mse.hit.edu.cn.json")
		if rs = fetcher.fetch
			latest_tag_id = rs
		end

		fetcher = PBGeneralFetcher.new("./cwc.hit.edu.cn.json")
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
