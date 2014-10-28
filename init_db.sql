/*
 This is a initialize script for build the database structure.
 Requirement: 
 每个Object有两个TAG，分别表示Department和Type，要求数据库的格式支持对TAG的查询。
 1. 用户查询：最新的10条计算机学院的新闻（创建每个学院最新10条HNObject
    对象的索引），如果阅读完毕，则可以支持继续查询11-20条计算机学院的新闻。
 2. 用户打开App主页将自动显示最新获取到的25条新闻和公告（创建所有Department中的最新
    25个HNObject对象的索引）。如果阅读完毕，则不需要支持继续查询，故可以提前创建索引。
 */
 
 db version1 on 2014/10/28
 每个学院均有自己的table。table的attribute包括：date，title，jsonfilepath，tag（type），link。
 SQL的所有操作均在调用Mysql.rb。因此example使用branch with-a-easy-db，更改爬虫代码的时候只需更改table名字。
 /*我现在觉得迭代一过后确实是要加两个tag的table的，确实想想数据传输会简单*/
