require './PBBaseExtractor.rb'
require './PBGeneralRouter.rb'

class PBGeneralExtractor < PBBaseExtractor

	def title
		@cell.search('td[2]//a')[0].text.strip
	end

	def link
		@base_url + @cell.search('td[2]//a')[0]['href']
	end

	def date
		@cell.search('td[2]//a')[1]['title'].gsub('/', '-')
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