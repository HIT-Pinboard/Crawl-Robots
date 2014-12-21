require './PBBaseFetcher.rb'
require './PBGeneralExtractor.rb'

class PBGeneralFetcher < PBBaseFetcher

	def get_extractor(config_hash)
		PBGeneralExtractor.new(config_hash)
	end

	private :get_extractor

end