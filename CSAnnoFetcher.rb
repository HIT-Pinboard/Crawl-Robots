require './PBBaseFetcher.rb'

class CSAnnoFetcher < PBBaseFetcher

	def title_search(cell)
		# Subclass and change this
		cell.search('td//a')[0].text.strip
	end

	def link_search(cell, base_url = '')
		# Subclass and change this
		base_url + cell.search('td//a')[0]["href"]
	end

	def date_search(cell)
		# Subclass and change this
		cell.search('td[3]').text.strip
	end

	def detail_node_selector(doc, string, uri)
		doc.xpath(string.sub('%@', uri.query.split('/').last))
	end

	private :check_config, :fetch_core, :title_search, :link_search, :date_search, :detail_node_selector
	
end
