require './PBGeneralFetcher.rb'
require './CSAnnoFetcher.rb'
require './CSNewsFetcher.rb'
require './PBPushController.rb'
require 'open-uri'
require 'time'

interval = 3600

start_hour = 8
end_hour = 22

while true

	if Time.now.hour.between?(start_hour, end_hour)
		fetcher = PBGeneralFetcher.new("./sme.hit.edu.cn.json")
		fetcher.fetch

		fetcher = PBGeneralFetcher.new("./sa.hit.edu.cn.json")
		fetcher.fetch

		fetcher = PBGeneralFetcher.new("./power.hit.edu.cn.json")
		fetcher.fetch

		fetcher = PBGeneralFetcher.new("./jwc.hit.edu.cn.json")
		fetcher.fetch

		fetcher = PBGeneralFetcher.new("./ssc.hit.edu.cn.json")
		fetcher.fetch

		fetcher = PBGeneralFetcher.new("./rwxy.hit.edu.cn.json")
		fetcher.fetch

		fetcher = PBGeneralFetcher.new("./jtxy.hit.edu.cn.json")
		fetcher.fetch

		fetcher = PBGeneralFetcher.new("./chemeng.hit.edu.cn.json")
		fetcher.fetch

		fetcher = CSAnnoFetcher.new("./cs.hit.edu.cn_anno.json")
		fetcher.fetch

		fetcher = CSNewsFetcher.new("./cs.hit.edu.cn_news.json")
		fetcher.fetch
		
		fetcher = PBGeneralFetcher.new("./mse.hit.edu.cn.json")
		fetcher.fetch

		fetcher = PBGeneralFetcher.new("./cwc.hit.edu.cn.json")
		fetcher.fetch

		pushController = PBPushController.new
		pushController.check_update

	end
	puts "[INFO] main thread go to sleep #{interval}"
	sleep(interval)
end
