require 'json'
require 'time'
require 'digest'
require './PBDBConnector.rb'

class PBNewsObject

	def initialize(object, website, tag)
		@object = object
		@website = website
		@tags = [tag]
	end

	def save
		save_local
		save_db
	end

	def save_local
		if !Dir.exist?@website
			Dir.mkdir(@website)
		end

		@filename = Digest::SHA1.hexdigest(@object["title"]+trim_date)
		@filePath = @website + '/' + @filename + '.json'
		@object["tags"] = @tags
		string = JSON.pretty_generate(@object)
		File.open(@filePath, 'w') { |file|
			file.write(string)
			puts "[INFO]: #{@filename} write to disk"
		}
	end

	def save_db
		conn = PBDBConn.new
		hash = {
			"title" => @object["title"],
			"date" => trim_date,
			"tags" => @tags,
			"link" => '/' + @filePath
		}
		conn.save(hash)
	end

	def trim_date
		object_date = @object["date"]

		date_year = object_date.split(' ').first.split('-')[0].to_i
		date_month = object_date.split(' ').first.split('-')[1].to_i
		date_day = object_date.split(' ').first.split('-')[2].to_i
		date_hour = object_date.split(' ').last.split('-')[0].to_i
		date_minite = object_date.split(' ').last.split('-')[1].to_i
		date_second = object_date.split(' ').last.split('-')[2].to_i

		format('%04d-%02d-%02d %02d:%02d:%02d', date_year, date_month, date_day, date_hour, date_minite, date_second)
	end

	private :save_local, :save_db, :trim_date

end