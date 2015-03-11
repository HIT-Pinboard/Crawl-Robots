require 'PBRobot'
require './CSRouter.rb'

class CSNewsExtractor < PBRobot::Extractor

	def title
		@cell.search('div/div[1]/div/h2/a').text.strip
	end

	def link
		@base_url + @cell.search('div/div[1]/div/h2/a')[0]['href']
	end

	def date
		text = @cell.search('div/div[1]/div/div/span/text()[2]').text.strip
		text.delete(' ').gsub('年', '-').gsub('月', '-').gsub('日', ' ')
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
		CSRouter.new
	end

	private :get_router

end