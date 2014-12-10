require 'json'
require 'time'
require 'digest'
require './PBDBConnector.rb'

class PBNewsObject

	def initialize(object, website, tag)
		@object = object
		@website = website
		@tag = tag
	end

	def save(db_conn)
		@conn = db_conn
		save_local
		save_db
	end

	def save_local
		if !Dir.exist?@website
			Dir.mkdir(@website)
		end

		@filename = Digest::SHA1.hexdigest(@object["title"]+trim_date)
		@filepath = @website + '/' + @filename + '.json'
		@object["tag"] = @tag
		string = JSON.pretty_generate(@object)
		File.open(@filepath, 'w') { |file|
			file.write(string)
			puts "[INFO]: #{@filename} write to disk"
		}
	end

	def save_db
		hash = {
			"title" => @object["title"],
			"date" => trim_date,
			"tag" => @tag,
			"filepath" => '/' + @filepath,
			"link" => @object["link"]
		}
		@conn.save(hash)
	end

	def trim_date
		object_date = @object["date"]

		date_year = object_date.split(/\/|-|:|\s/)[0].to_i
		date_month = object_date.split(/\/|-|:|\s/)[1].to_i
		date_day = object_date.split(/\/|-|:|\s/)[2].to_i
		if object_date.object_date.split(/\/|-|:|\s/).count < 6
			date_hour = 10
			date_minite = 0
			date_second = 0
		else
			date_hour = object_date.split(/\/|-|:|\s/)[3].to_i
			date_minite = object_date.split(/\/|-|:|\s/)[4].to_i
			date_second = object_date.split(/\/|-|:|\s/)[5].to_i
		end
		format('%04d-%02d-%02d %02d:%02d:%02d', date_year, date_month, date_day, date_hour, date_minite, date_second)
	end

	private :save_local, :save_db, :trim_date

end