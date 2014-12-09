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
	end

	def save(hash)
		sql = "INSERT INTO PDB (Title,Time,Tag,FilePath,URL) VALUES (?, ?, ?, ?, ?)"
		st = @conn.prepare(sql)
		st.execute(hash["title"], hash["date"], hash["tag"], hash["filePath"], hash["URL"])
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