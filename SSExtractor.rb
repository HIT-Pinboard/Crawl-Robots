require './PBBaseExtractor.rb'
require './PBGeneralRouter.rb'

class SSExtractor < PBBaseExtractor

	def title
		@cell.search('a').text.strip
	end

	def link
		@base_url + @cell.search('a')[0]['href']
	end

	def date
		text = @cell.search('span').text.strip
		text.delete(' ').delete('(').delete(')')
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