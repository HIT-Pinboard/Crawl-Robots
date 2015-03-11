require 'PBRobot'

class PBGeneralRouter < PBRobot::Router

	def tags
		tags = []
		if node = get_tags_node
			node.each do |tag|
				tags << tag.text
			end
		end
		tags
	end

	def get_content_node
		if content_xpath = xpath_hash["content"]
			if content_xpath.is_a? Array
				content_xpath.map{ |k| doc.xpath(k) }.reject { |k| k.count == 0 }.first
			else
				doc.xpath(content_xpath)
			end
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