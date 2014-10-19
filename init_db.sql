/*
 This is a initialize script for build the database structure.
 Requirement: 
 每个Object有两个TAG，分别表示Department和Type，要求数据库的格式支持对TAG的查询。
 1. 用户查询：最新的10条计算机学院的新闻（创建每个学院最新10条HNObject
    对象的索引），如果阅读完毕，则可以支持继续查询11-20条计算机学院的新闻。
 2. 用户打开App主页将自动显示最新获取到的25条新闻和公告（创建所有Department中的最新
    25个HNObject对象的索引）。如果阅读完毕，则不需要支持继续查询，故可以提前创建索引。
 */