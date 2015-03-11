require 'mechanize'
require 'open-uri'

module PBRobot

  class Fetcher

    def initialize(conf_filepath)
      begin
        @config = JSON.parse(open(conf_filepath).read)
      rescue Errno::ENOENT
        puts "[FATAL]: config file not found"
        exit 1
      end
    end

    def fetch(&block)
      latest_tag_id = nil
      @config["website"].each do |host, value|
        value.each do |url|
          puts "[INFO]: #{url} fetcher start"
          if rs = fetch_core(host, url, &block)
            latest_tag_id = rs
          end
        end
      end
      latest_tag_id
    end

    def fetch_core(base, url, &block)
      conf_hash = @config[url]
      raise "[FATAL]: config file incorrect" if !check_config(conf_hash)

      main_thread = Mechanize.new
      minion_thread = Mechanize.new

      begin
        news_index = main_thread.get(url)
        news_index.encoding = conf_hash["encoding"]
      rescue Net::HTTP::Persistent::Error
        sleep(300)
        retry
      rescue Mechanize::ResponseCodeError => e
        puts "[ERROR]: #{e.inspect}"
        exit 1
      end

      base_url = @config["base_url"]

      # Incrementally Update
      should_stop = false
      stop_index = 0
      stop_link = nil

      last_update_path = @config["last_update_path"]
      
      begin
        last_update = JSON.parse(open(last_update_path).read)
      rescue Errno::ENOENT
        puts '[INFO]: new last_update json created'
        last_update = {}
      end

      if !last_update.has_key?url
        last_update[url]= {}
        puts "[INFO]: new last_update json section #{url} created"
      end

      latest_tag_id = nil

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
          rescue Net::HTTP::Persistent::Error
            sleep(300)
            retry
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

          latest_tag_id = block.call(obj, base)

          stop_index += 1
        end

        if link = news_index.link_with(:text => conf_hash["next_text"])
          begin
            news_index = link.click
            news_index.encoding = conf_hash["encoding"]
          rescue Net::HTTP::Persistent::Error
            sleep(300)
            retry
          rescue Mechanize::ResponseCodeError => e
            puts "[ERROR]: #{e.inspect}"
            exit 1
          end
        else
          break
        end
        
      end

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
      latest_tag_id
    end

    def check_config(hash)
      hash.has_key?("encoding") && hash.has_key?("news_table") && hash.has_key?("next_text")
    end

    def get_extractor(conf_hash)
      PBRobot::Extractor.new(conf_hash)
    end

    private :fetch_core ,:check_config, :get_extractor

  end

end