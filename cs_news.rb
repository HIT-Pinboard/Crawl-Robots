#!/usr/local/bin ruby
require 'mechanize'
require 'open-uri'
require './HTMLNodeParser.rb'
require './NewsObject.rb'
# A example of crawling down sme.hit.edu.cn
# 学院新闻 http://sme.hit.edu.cn/news/main.asp?cataid=A00010003
# Encoding: GB2312
main_thread = Mechanize.new
minion_thread = Mechanize.new
news_index = main_thread.get('http://cs.hit.edu.cn/')
news_index.encoding = 'UTF-8'
base_url = 'http://cs.hit.edu.cn/'
# Incrementally update
should_stop = false
stop_index = 0
stop_link = nil
filePath = 'cs.hit.edu.cn/news/last_update.json'
if File.exist?filePath
	file = File.read(filePath, :encoding => 'UTF-8')
	last_update = JSON.parse(file)
else
	last_update = {}
end
while !should_stop do
	table = news_index.search('.node-header') # use XPath query to get news_links
	table.each do |cell|
		news_title = cell.search('a')[0].text.strip
		news_link = base_url + cell.search('a')[0]["href"] 
		news_date = cell.search('./div/div/span/text()[2]').text.strip
		if stop_link == nil
			stop_link = news_link
		end
		if last_update["link"] != nil && news_link == last_update["link"]
			should_stop = 1
			break
		end
		news_page = minion_thread.get(news_link);
		doc = Nokogiri::HTML(news_page.body, nil, 'UTF-8')
		parser = ACHTMLNodeParser.new(doc.xpath('//*[@id="'+cell.search('a')[0]["href"][4...8]+'-'+cell.search('a')[0]["href"][9...13]+'"]/div[2]/div[1]/div/div'), base_url)
		parser.parse
		news_date = news_date.delete(' ').gsub('年', '-').gsub('月', '-').gsub('日', ' ')+ DateTime.now.to_time.to_s.split(' ')[1] +' ' + DateTime.now.to_time.to_s.split(' ')[1]
		news_title = news_title.gsub('/', '-')
		obj = {
			"title" => news_title,
			"link" => news_link,
			"date" => news_date,
			"content" => parser.string,
			"imgs" => parser.imgs
		}
		news = NewsObject.new(HNDepart::CS, HNType::NEWS, obj)
		news.save
		stop_index += 1
	end
	if link = news_index.link_with(:text => '下一页 ›')
		news_index = link.click
		news_index.encoding = 'UTF-8'
	else
		break
	end
end
last_update = {
	"date" => DateTime.now.to_time.to_s[0..-7],
	"link" => stop_link,
	"count" => stop_index
}
File.open(filePath, 'w:UTF-8') { |file|
	string = JSON.pretty_generate(last_update)
	file.write(string)
}
