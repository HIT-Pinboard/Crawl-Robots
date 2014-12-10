require 'mysql'
require 'json'
require 'open-uri'

class PBDBConn

	def initialize(conf_filepath = './db.json')
		if File.exist?conf_filepath
			@conf = JSON.parse(open(conf_filepath).read)
		else
			raise "[FATAL]: db config file not found"
		end
		raise "[FATAL]: db config file incorrect" if !check_config(@conf)
		@conn = Mysql.new(@conf["db_address"], @conf["db_username"], @conf["db_password"], @conf["db_database"])
		@conn.query("CREATE TABLE IF NOT EXISTS PDB(Time VARCHAR(200),Title NVARCHAR(200),FilePath NVARCHAR(300),Tag VARCHAR(15),URL VARCHAR(100),PRIMARY KEY(Tag,URL));")
		@conn.query("CREATE TABLE IF NOT EXISTS UserInfo(UUID VARCHAR(64),UserTags VARCHAR(30),PRIMARY KEY(UUID,UserTags));")
	end

	def save(hash)
		sql = "INSERT INTO PDB (Time,Title,FilePath,Tag,URL) VALUES (?, ?, ?, ?, ?)"
		st = @conn.prepare(sql)
		st.execute(hash["date"], hash["title"], hash["filePath"], hash["tag"], hash["URL"])
	end

	def getNewsListAll(m, n)
		sql = "SELECT * FROM PDB ORDER BY TIME DESC LIMIT ?,?"
		st = @conn.prepare(sql)
		Stmt.new(st.execute(m, n))
    end

    def getNewsList(tags, m, n)
    	stmt = []
    	tags.count.times {
    		stmt << 'Tag = ?'
    	}
    	sql = "SELECT * FROM PDB WHERE #{stmt.join(' OR ')} ORDER BY TIME DESC LIMIT ?,?;"
    	st = @conn.prepare(sql)
    	Stmt.new(st.execute(*tags, m, n))
    end
    
    def updateID(uuid, tags)
    	if uuid.length == 64
    		tag = tags.join(',')
			sql = "INSERT INTO UserInfo (UUID, UserTags) VALUES (?, ?)"
			st = @conn.prepare(sql)
			st.execute(uuid, tag)
		else
			raise "[FATAL]: device uuid is not 64 bits"
		end
    end

    def removeID(uuid)
    	if uuid.length == 64
    		sql = "DELETE FROM UserInfo WHERE UUID = ?"
			st = @conn.prepare(sql)
			st.execute(uuid)
    	else
    		raise "[FATAL]: device uuid is not 64 bits"
    	end
    end
    
    def getUsersList
    	@conn.query("SELECT * FROM UserInfo")
    end

	def close
		@conn.close
	end

	def check_config(hash)
		return false if !hash.has_key?"db_address"
		return false if !hash.has_key?"db_username"
		return false if !hash.has_key?"db_password"
		return false if !hash.has_key?"db_database"
		true
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