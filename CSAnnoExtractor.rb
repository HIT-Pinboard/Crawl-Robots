require 'PBRobot'
require './CSRouter.rb'

class CSAnnoExtractor < PBRobot::Extractor

	def title
		@cell.search('td//a')[0].text.strip
	end

	def link
		@base_url + @cell.search('td//a')[0]["href"]
	end

	def date
		@cell.search('td[3]').text.strip
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