require './PBBaseRouter.rb'

class PBGeneralRouter < PBBaseRouter

	def get_content_node
		if content_xpath = xpath_hash["content"]
			doc.xpath(content_xpath)
		end
	end

	def get_tags_node
		if content_xpath = xpath_hash["tags"]
			doc.xpath(content_xpath)
		end
	end

	def get_date_node
		if content_xpath = xpath_hash["date"]
			doc.xpath(content_xpath)
		end
	end

end