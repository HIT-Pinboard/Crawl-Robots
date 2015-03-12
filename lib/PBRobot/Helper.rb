require 'open-uri'
require 'json'

module PBRobot

  class Helper

    def self::json_with_filepath(filepath, options = {})
      begin
        json = JSON.parse(open(filepath).read)
      rescue Errno::ENOENT
        if options[:ignore_not_found]
          json = {}
        else
          puts "[FATAL]: file at #{filepath} not found"
          exit 1
        end
      rescue JSON::ParserError
        puts "[FATAL]: parse json failed"
        exit 1
      rescue Exception => e
        puts "[FATAL]: #{e.inspect}" 
        exit 1   
      end
    end

    def self::write_to_json(filepath, hash)
      begin
        File.open(filepath, 'w') { |file|
          file.write(JSON.pretty_generate(hash))
        }
      rescue Exception => e
        puts "[ERROR]: write to file failed with #{e.inspect}"
      end
    end

  end

end