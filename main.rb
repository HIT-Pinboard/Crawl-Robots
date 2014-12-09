require './SMEFetcher.rb'
require './SAFetcher'
require 'open-uri'

#fetcher = SMEFetcher.new("./sme.hit.edu.cn.json")
#fetcher.fetch

fetcher = SAFetcher.new("./sa.hit.edu.cn.json")
fetcher.fetch

