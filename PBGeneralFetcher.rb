require './PBBaseFetcher.rb'

class PBGeneralFetcher < PBBaseFetcher

	def title_search(cell)
		# Subclass and change this
		cell.search('td[2]//a')[0].text.strip
	end

	def link_search(cell, base_url = '')
		# Subclass and change this
		base_url + cell.search('td[2]//a')[0]['href']
	end

	def date_search(cell)
		# Subclass and change this
		cell.search('td[2]//a')[1]['title'].gsub('/', '-')
	end

	private :check_config, :fetch_core, :title_search, :link_search, :date_search
	
end
