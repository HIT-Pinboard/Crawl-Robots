require 'open-uri'
require 'json'

class PBTAO

	def initialize(taglist_filepath = './tagsList.json')
		if File.exist?taglist_filepath
			@tagLists = JSON.parse(open(taglist_filepath).read)
		else
			raise "[FATAL]: tags list file not found"
		end
	end

	def query(tag_value)
		tag_array = tag_value.split('.')
		return_array = []
		if tag_array.count < 2
			@tagLists["data"].each do |tag|
				if tag["value"] == tag_array.first
					tag["children"].each do |child_tag|
						return_array << child_tag["value"]
					end
				end
			end
		else
			return_array << tag_value
		end
		return_array
	end

	def full_name(tag_value)
		tag_array = tag_value.split('.')
		if tag_array.count < 2
			@tagLists["data"].each do |tag|
				return tag["name"] if tag["value"] == tag_array.first
			end
		else
			@tagLists["data"].each do |tag|
				if tag["value"] == tag_array.first
					tag["children"].each do |child_tag|
						return child_tag["name"] if child_tag["value"] == tag_value
					end
				end
			end
		end
		nil
	end

end