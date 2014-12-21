require 'mechanize'
require 'open-uri'
require './PBNewsObject.rb'
require './PBDBConnector.rb'
require './PBBaseExtractor.rb'

class PBBaseFetcher

	def initialize(conf_filepath)
		if File.exist?conf_filepath
			@config = JSON.parse(open(conf_filepath).read)
		else
			raise "[FATAL]: config file not found"
		end
	end

	def fetch
		@config["website"].each do |key, value|
			value.each do |akey|
				puts "[INFO]: #{akey} fetcher start"
				fetch_core(key, akey)
			end
		end
	end

	def fetch_core(base, url)
		conf_hash = @config[url]
		raise "[FATAL]: config file incorrect" if !check_config(conf_hash)

		main_thread = Mechanize.new
		minion_thread = Mechanize.new

		conn = PBDBConn.new

		news_index = main_thread.get(url)
		news_index.encoding = conf_hash["encoding"]

		base_url = @config["base_url"]

		# Incrementally Update
		should_stop = false
		stop_index = 0
		stop_link = nil

		last_update_path = @config["last_update_path"]
		if File.exist?last_update_path
			last_update = JSON.parse(open(last_update_path).read)
		else
			last_update = {}
			puts '[INFO]: new last_update json created'
		end

		if !last_update.has_key?url
			last_update[url]= {}
			puts "[INFO]: new last_update json section #{url} created"
		end

		while !should_stop do
			table = news_index.search(conf_hash["news_table"])

			table.each do |cell|
				
				extractor = get_extractor(conf_hash)
				extractor.base_url=base_url
				extractor.cell=cell

				news_link = extractor.link

				if stop_link == nil
					stop_link = news_link
				end

				if last_update[url]["link"] != nil && news_link == last_update[url]["link"]
					should_stop = 1
					break
				end

				begin
					news_page = minion_thread.get(news_link);
					news_page.encoding = conf_hash["encoding"]
				rescue Mechanize::ResponseCodeError => e
					puts "[ERROR]: #{e.inspect}"
					next
				end

				extractor.detail_page=news_page

				obj = {
					"title" => extractor.title,
					"link" => extractor.link,
					"date" => extractor.date,
					"content" => extractor.content,
					"imgs" => extractor.imgs,
					"tags" => extractor.tags
				}

				news = PBNewsObject.new(obj, base)
				news.save(conn)

				stop_index += 1
			end

			if link = news_index.link_with(:text => conf_hash["next_text"])
				news_index = link.click
				news_index.encoding = conf_hash["encoding"]
			else
				break
			end
		end

		conn.close

		# Incrementally Update Write
		last_update[url] = {
			"date" => Time.now.to_time.to_s[0..-7],
			"link" => stop_link,
			"count" => stop_index
		}

		File.open(last_update_path, 'w') { |file|
			string = JSON.pretty_generate(last_update)
			file.write(string)
		}
	end

	def check_config(hash)
		hash.has_key?("encoding") && hash.has_key?("news_table") && hash.has_key?("next_text")
	end

	def get_extractor(conf_hash)
		PBBaseExtractor.new(conf_hash)
	end

	private :check_config, :get_extractor

end