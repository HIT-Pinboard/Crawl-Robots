require './SMEFetcher.rb'
require './SAFetcher.rb'
require './JWCFetcher.rb'
require './CWCFetcher.rb'
require 'open-uri'

#fetcher = SMEFetcher.new("./sme.hit.edu.cn.json")
#fetcher.fetch

# fetcher = SAFetcher.new("./sa.hit.edu.cn.json")
# fetcher.fetch

# fetcher = JWCFetcher.new("./jwc.hit.edu.cn.json")
# fetcher.fetch

fetcher = CWCFetcher.new("./cwc.hit.edu.cn.json")
fetcher.fetch