require 'mysql'
require 'json'
require 'open-uri'

class PBDBConn

	def initialize(conf_filepath = './db.json')
		begin
			@conf = JSON.parse(open(conf_filepath).read)
		rescue Errno::ENOENT
			puts "[FATAL]: db config file not found"
      exit 1
		end
		raise "[FATAL]: db config file incorrect" if !check_config(@conf)
		@conn = Mysql.new(@conf["db_address"], @conf["db_username"], @conf["db_password"], @conf["db_database"])
	end

	def save(hash)
		latest_tag_id = nil
		sql = "INSERT INTO `NewsObject` (`Title`,`Date`,`Filepath`,`Link`) VALUES (?,?,?,?)"
		st = @conn.prepare(sql)
		st.execute(hash["title"], hash["date"], hash["filepath"], hash["link"])
		insert_id = st.insert_id
		hash["tags"].uniq.each do |tag|
			sql = "INSERT INTO `Object_Tags` (`ID_News`,`Tag_Value`) VALUES (?,?)"
			st = @conn.prepare(sql)
			st.execute(insert_id, tag)
			latest_tag_id = st.insert_id
		end
		latest_tag_id
	end

	def getNewsListAll(m, n)
		result = []
		sql = "SELECT * FROM `NewsObject` ORDER BY `Date` DESC LIMIT ?,?"
		st = @conn.prepare(sql)
		Stmt.new(st.execute(m, n)).each_hash do |ele|
			id = ele["ID"]
			hash = ele

			tags = []
    		sql = "SELECT `Tag_Value` FROM `Object_Tags` WHERE `ID_News` = ?"
    		st = @conn.prepare(sql)
    		Stmt.new(st.execute(id)).each_hash do |h|
    			tags << h["Tag_Value"]
    		end

    		hash["Tags"] = tags
    		result << hash
		end
		result
    end

    def getNewsList(tags, m, n)
    	result = []
    	sql = "SELECT DISTINCT `NewsObject`.`ID`,`Date` FROM `NewsObject` INNER JOIN `Object_Tags` ON `NewsObject`.`ID` = `Object_Tags`.`ID_News` WHERE #{(['`Tag_Value` = ?'] * tags.count).join(' OR ')} ORDER BY `Date` DESC LIMIT ?,?"
    	st = @conn.prepare(sql)
    	Stmt.new(st.execute(*tags, m, n)).each_hash do |ele|
    		id = ele["ID"]
    		hash = nil

    		sql = "SELECT `Title`,`Date`,`Filepath`,`Link` FROM `NewsObject` WHERE `ID` = ?"
    		st = @conn.prepare(sql)
    		Stmt.new(st.execute(id)).each_hash do |h|
    			hash = h
    		end
    		
    		tags = []
    		sql = "SELECT `Tag_Value` FROM `Object_Tags` WHERE `ID_News` = ?"
    		st = @conn.prepare(sql)
    		Stmt.new(st.execute(id)).each_hash do |h|
    			tags << h["Tag_Value"]
    		end

    		hash["Tags"] = tags
    		result << hash
    	end
    	result
    end
    
    def updateID(uuid, tags)
    	if uuid.length == 64
    		tag = tags.join(',')
			sql = "INSERT INTO `Subscriber` (`UUID`, `Tags`) VALUES (?, ?)"
			st = @conn.prepare(sql)
			st.execute(uuid, tag)
		else
			raise "[FATAL]: device uuid is not 64 bits"
		end
    end

    def removeID(uuid)
    	if uuid.length == 64
    		sql = "DELETE FROM `Subscriber` WHERE `UUID` = ?"
			st = @conn.prepare(sql)
			st.execute(uuid)
    	else
    		raise "[FATAL]: device uuid is not 64 bits"
    	end
    end
    
    def getUsersList
    	@conn.query("SELECT * FROM `Subscriber`")
    end

    def getTagsCount(tags, last_tag_id)
    	if tags.count > 0
	    	sql = "SELECT DISTINCT `ID_News` FROM `Object_Tags` WHERE `ID` > ? AND (#{(['`Tag_Value` = ?'] * tags.count).join(' OR ')})"
	    	st = @conn.prepare(sql)
	    	st.execute(last_tag_id, *tags)
	    	return st.num_rows
	    end
	    0
    end

	def close
		@conn.close
	end

	def check_config(hash)
		hash.has_key?("db_address") && hash.has_key?("db_username") && hash.has_key?("db_password") && hash.has_key?("db_database")
	end

	private :check_config
end


# issue here: http://stackoverflow.com/questions/17083383/fetch-mysql-prepared-statement-as-array-of-hashes
class Stmt
	def each_hash
		fields = @target.result_metadata.fetch_fields.map do |f| f.name end 
		@target.each do |x| 
			hash = {}
			fields.zip(x).each do |pair|
				hash[pair[0]] = pair[1]
			end 
			yield hash
		end 
	end 

	def initialize(target)
		@target = target
	end 

	def method_missing(name, *args, &block)
		@target.send(name, *args, &block)
	end 
end