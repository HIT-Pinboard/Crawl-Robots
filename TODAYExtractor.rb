require './PBBaseExtractor.rb'
require './PBGeneralRouter.rb'

class TodayExtractor < PBBaseExtractor

	def title
		@cell.search('a').text.strip
	end

	def link
		@base_url + @cell.search('a')[0]['href']
	end

	def date
		if router.can_parse? && k = router.date
			k.match(/\d+-\d+-\d+\s\d+:\d+:\d+/)[0]
		else
			@cell.children.last.text.match(/\d+-\d+-\d+(\s\d+:\d+:\d+)?/)[0]
		end
	end

	def tags
		@conf_hash["tags"]
	end

	def content
		if router.can_parse?
			router.content 
		else
			"请进入原链接查看本文！"
		end
	end

	def imgs
		router.imgs if router.can_parse?
	end

	def get_router
		PBGeneralRouter.new
	end

	private :get_router

end
