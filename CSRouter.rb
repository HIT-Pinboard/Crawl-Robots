require 'PBRobot'

class CSRouter < PBRobot::Router

	def get_content_node
		uri = @page.uri
		if content_xpath = xpath_hash["content"]
			doc.xpath(content_xpath.sub('%@', uri.query.split('/').last))
		end
	end

end