require 'mechanize'
require 'Nokogiri'
require 'open-uri'
require './PBHTMLNodeParser.rb'
require './PBNewsObject.rb'
require './PBDBConnector.rb'

class PBBaseFetcher

	def initialize(config_filepath)
		if File.exist?config_filepath
			@config = JSON.parse(open(config_filepath).read)
			@last_update_path = @config["last_update_path"]
		else
			raise "[FATAL]: config file not found"
		end
	end

	def fetch
		@config["website"].each do |key, value|
			value.each do |akey|
				fetch_core(key, akey)
			end
		end
	end

	def fetch_core(base, url)
		config_hash = @config[url]
		raise "[FATAL]: config file incorrect" if check_config(config_hash)
		main_thread = Mechanize.new
		minion_thread = Mechanize.new

		conn = PBDBConn.new

		news_index = main_thread.get(url)
		news_index.encoding = config_hash["encoding"]

		base_url = @config["base_url"]

		# Incrementally Update
		should_stop = false
		stop_index = 0
		stop_link = nil

		if File.exist?@last_update_path
			last_update = JSON.parse(open(@last_update_path).read)
		else
			last_update = {}
			puts '[INFO]: new last_update json created'
		end

		if !last_update.has_key?base
			last_update[base] = {}
			puts "[INFO]: new last_update json section: #{base} created"
		end

		tag = config_hash["tag"]
		if !last_update[base].has_key?tag
			last_update[base][tag]= {}
			puts "[INFO]: new last_update json section: #{base}:#{tag} created"
		end

		while !should_stop do
			table = news_index.search(config_hash["news_table"])

			table.each do |cell|
				news_title = title_search(cell)
				news_link = link_search(cell, base_url)
				news_date = date_search(cell)

				if stop_link == nil
					stop_link = news_link
				end

				if last_update[base][tag]["link"] != nil && news_link == last_update[base][tag]["link"]
					should_stop = 1
					break
				end

				begin
					news_page = minion_thread.get(news_link);
					news_page.encoding = config_hash["encoding"]
				rescue Mechanize::ResponseCodeError => e
					puts "[ERROR]: #{e.inspect}"
					next
				end
				
				next if news_page.uri.host != URI.parse(base_url).host

				doc = Nokogiri::HTML(news_page.body, nil, config_hash["encoding"])

				parser = PBHTMLNodeParser.new(doc.xpath(config_hash["news_detail_root"]), base_url)
				parser.parse

				obj = {
					"title" => news_title,
					"link" => news_link,
					"date" => news_date,
					"content" => parser.string,
					"imgs" => parser.imgs
				}
				news = PBNewsObject.new(obj, base, tag)
				news.save(conn)

				stop_index += 1
			end

			if link = news_index.link_with(:text => config_hash["next_text"])
				news_index = link.click
				news_index.encoding = config_hash["encoding"]
			else
				break
			end
		end

		conn.close

		# Incrementally Update Write
		last_update[base][tag] = {
			"date" => Time.now.to_time.to_s[0..-7],
			"link" => stop_link,
			"count" => stop_index
		}

		File.open(@last_update_path, 'w') { |file|
			string = JSON.pretty_generate(last_update)
			file.write(string)
		}
	end

	def check_config(hash)
		return false if !hash.has_key?"encoding"
		return false if !hash.has_key?"tags"
		return false if !hash.has_key?"news_table"
		return false if !hash.has_key?"news_detail_root"
		return false if !hash.has_key?"next_text"
		true
	end

	def title_search(cell)
		# Subclass and change this
	end

	def link_search(cell, base_url = '')
		# Subclass and change this
	end

	def date_search(cell)
		# Subclass and change this
	end

	private :check_config, :fetch_core, :title_search, :link_search, :date_search

end