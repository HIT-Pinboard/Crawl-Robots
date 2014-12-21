require './PBHTMLNodeParser.rb'
require 'open-uri'
require 'json'

class PBBaseRouter

	def initialize(conf_filepath = './router.json')
		if File.exist?conf_filepath
			@conf = JSON.parse(open(conf_filepath).read)
		else
			raise "[FATAL]: router config file not found"
		end
	end

	def page=(page)
		@page = page
	end

	def encoding=(encoding = 'utf-8')
		@encoding = encoding
	end

	def base_url=(base_url = '')
		@base_url = base_url
	end

	def xpath_hash
		return if !@page
		@conf.each do |key, value|
			uri_pattern = Regexp.new(key)
			next if @page.uri.to_s.match(uri_pattern) == nil
			break value
		end
	end

	def content
		if parser
			parser.parse if parser.string == ""
			parser.string
		end
	end

	def imgs
		if parser
			parser.parse if parser.string == ""
			parser.imgs
		end
	end

	def tags
		if node = get_tags_node
			node.text
		end
	end

	def date
		if node = get_tags_node
			node.text
		end
	end

	def get_content_node
		
	end

	def get_tags_node
		
	end

	def get_date_node
		
	end
	
	def doc
		@doc = Nokogiri::HTML(@page.body, nil, @encoding) if !@doc
		@doc
	end

	def parser
		if node = get_content_node
			@parser = PBHTMLNodeParser.new(node, @base_url) if !@parser
			@parser
		end
	end

	private :doc, :parser
end