
# NewsObject class
require 'json'
require 'date'
class HNDepart
	TODAY = 0
	CS = 1
	SME = 2
	JWC = 3
	CWC = 4
end
class HNType
	NEWS = 0
	ANNOUNCEMENT = 1
end
class NewsObject
	def initialize(department, type, object)
		@department = department
		@type = type
		@object = object
	end
	def type
		case @type
		when HNType::NEWS
			"news"
		when HNType::ANNOUNCEMENT
			"announcement"
		else
			"other"
		end
	end
	def department
		case @department
		when HNDepart::TODAY
			"today.hit.edu.cn"
		when HNDepart::JWC
			"jwc.hit.edu.cn"
		when HNDepart::CS
			"cs.hit.edu.cn"
		when HNDepart::SME
			"sme.hit.edu.cn"
		when HNDepart::CWC
			"cwc.hit.edu.cn"
		else
			"other"
		end
	end
	def date
		if @object.has_key?"date"
			dateString = @object["date"]
			date = dateString.split(' ')[0]
			time = dateString.split(' ')[1]
			DateTime.new(date.split('-')[0].to_i,
			date.split('-')[1].to_i,
			date.split('-')[2].to_i,
			time.split(':')[0].to_i,
			time.split(':')[1].to_i,
			time.split(':')[2].to_i, '+8')
		end
	end
	def save
		date = self.date
	# Save to local
		if !Dir.exist?self.department
			Dir.mkdir(self.department)
		end
		if !Dir.exist?(self.department+'/'+self.type)
			Dir.mkdir(self.department+'/'+self.type)
		end
		if @object.has_key?("title")
			filePath = self.department + '/' + self.type + '/' + date.year.to_s + '-' + format('%02d', date.month) + '-' + format('%02d', date.day) + '-' + self.type + '-' + @object["title"] + '.json'
			string = self.toJSON
			File.open(filePath, 'w:UTF-8') { |file|
			file.write(string)
			}
		end
	# Save to DB
	#def savedb
	#	filePath = self.department + '/' + self.type + '/' + date.year.to_s + '-' + format('%02d', date.month) + '-' + format('%02d', date.day) + '-' + self.type + '-' + @object["title"] + '.json'
	#	 conn.query("insert into sme values('#{@object["date"]}','#{@object["title"]}','#{filePath}','#{self.type}','#{@object["link"]}')")
	#end
	# To-do
	end
	def toJSON
		JSON.pretty_generate(@object)
	end
end
