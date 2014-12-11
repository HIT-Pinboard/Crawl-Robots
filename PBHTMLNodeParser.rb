require 'nokogiri'
require 'uri'

class PBHTMLNodeParser

	def initialize(root, base_url = "")
		@root = root
		@string = ""
		@imgs = []
		@base_url = base_url
	end

	def parse
		if @root.is_a?Nokogiri::XML::NodeSet
			iterativePreorder(@root.first)
		elsif @root.is_a?Nokogiri::XML::Element
			iterativePreorder(@root)
		else
			puts '[ERROR]: Unknown class, must be Nokogiri::XML::NodeSet or Nokogiri::XML::Element'
		end
	end

	def iterativePreorder(node)
		case node.name
		when "text"
			@string += node.text.strip+'\n' if node.text.strip.length != 0
		when "img"
			@string += '#!-- Images['+@imgs.count.to_s+'] --!#\n'
			if node[:src] =~ URI::regexp
				@imgs << node[:src]
			else
				@imgs << @base_url+node[:src]
			end
		when "table"
			@string += node.to_s.encode('utf-8')
			return
		end
		node.children.each do |child|
			iterativePreorder(child)
		end
	end

	def string
		@string
	end

	def imgs
		@imgs
	end

	private :iterativePreorder

end