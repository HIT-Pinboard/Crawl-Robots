require './PBBaseFetcher.rb'
require './TODAYExtractor.rb'

class TODAYFetcher < PBBaseFetcher

	def get_extractor(config_hash)
		TODAYExtractor.new(config_hash)
	end

	private :get_extractor

end
