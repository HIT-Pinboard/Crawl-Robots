require './PBBaseExtractor.rb'
require './PBGeneralRouter.rb'

class TODAYExtractor < PBBaseExtractor

	def title
		@cell.search('a').text.strip
	end

	def link
		@base_url + @cell.search('a')[0]['href']
	end

	def date
		@cell.search('a')[0]['href'][6..15]
	end

	def tags
		@conf_hash["tags"]
	end

	def content
		router.content
	end

	def imgs
		router.imgs
	end

	def get_router
		PBGeneralRouter.new
	end

	private :get_router

end
