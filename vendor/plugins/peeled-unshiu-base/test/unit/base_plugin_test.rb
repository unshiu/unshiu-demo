require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'

module BasePluginTestModule
  
  class << self
    def included(base)
      base.class_eval do
      end
    end
  end
  
  define_method('test: news一覧を取得する') do 
    
    response_sample = <<EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <?xml-stylesheet href="/css/rss10.xsl" type="text/xsl"?>
    <rdf:RDF xmlns:pheedo="http://www.pheedo.com/namespace/pheedo"
        xmlns="http://purl.org/rss/1.0/"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:slash="http://purl.org/rss/1.0/modules/slash/"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xml:lang="ja">
    	<channel rdf:about="http://japan.cnet.com/">
    		<title>unshiu news</title>
    		<link>http://unshiu.drecom.jp/news</link>
    		<description>unshiu</description>
    		<dc:language>ja</dc:language>

    		<dc:rights>Copyright (c) Drecom</dc:rights>
    		<dc:date>2009-01-26T19:38:01+09:00</dc:date>
    		<items>
    			<rdf:Seq>
    				<rdf:li rdf:resource="http://unshiu.drecom.jp/news/1"/>
    				<rdf:li rdf:resource="http://unshiu.drecom.jp/news/2"/>
    				<rdf:li rdf:resource="http://unshiu.drecom.jp/news/3"/>
    				<rdf:li rdf:resource="http://unshiu.drecom.jp/news/4"/>
    			</rdf:Seq>
    		</items>
    	</channel>
    	<image rdf:about="http://unshiu.drecom.jp/logo.gif">
    		<title>unshiu news</title>

    		<link>http://unshiu.drecom.jp</link>
    		<url>http://unshiu.drecom.jp/logo.gif</url>
    	</image>
    	<item rdf:about="http://unshiu.drecom.jp/news/1">
    		<title>[release][base]1.0.3</title>
    		<link>http://unshiu.drecom.jp/news/1</link>
    		<description>1.0.3をリリースしました</description>
    		<dc:date>2009-01-26T19:38:01+09:00</dc:date>
    	</item>
    	<item rdf:about="http://unshiu.drecom.jp/news/2">
    		<title>[release][base]1.1.0</title>
    		<link>http://unshiu.drecom.jp/news/2</link>
    		<description>1.1.0をリリースしました
    </description>
    		<dc:date>2009-01-26T19:38:01+09:00</dc:date>
    	</item>
    	
    	<item rdf:about="http://unshiu.drecom.jp/news/3">
    		<title>[release][abm]1.0.3</title>
    		<link>http://unshiu.drecom.jp/news/3</link>
    		<description>abm1.0.3をリリースしました
    </description>
    		<dc:date>2009-01-26T19:38:01+09:00</dc:date>
    	</item>
    	
    	<item rdf:about="http://unshiu.drecom.jp/news/4">
    		<title>お知らせ</title>
    		<link>http://unshiu.drecom.jp/news/4</link>
    		<description>お知らせ
    </description>
    		<dc:date>2009-01-26T19:38:01+09:00</dc:date>
    	</item>
    </rdf:RDF>
EOS
    
    BasePlugin.stubs(:rss).returns(RSS::Parser.parse(response_sample))
    
    base_news = BasePlugin.news
    
    assert_not_nil(base_news)
    assert_equal(base_news.size, 4)
  end
  
  define_method('test: プラグインのnewsを取得する') do 
    
    response_sample = <<EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <?xml-stylesheet href="/css/rss10.xsl" type="text/xsl"?>
    <rdf:RDF xmlns:pheedo="http://www.pheedo.com/namespace/pheedo"
        xmlns="http://purl.org/rss/1.0/"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:slash="http://purl.org/rss/1.0/modules/slash/"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xml:lang="ja">
    	<channel rdf:about="http://japan.cnet.com/">
    		<title>unshiu news</title>
    		<link>http://unshiu.drecom.jp/news</link>
    		<description>unshiu</description>
    		<dc:language>ja</dc:language>

    		<dc:rights>Copyright (c) Drecom</dc:rights>
    		<dc:date>2009-01-26T19:38:01+09:00</dc:date>
    		<items>
    			<rdf:Seq>
    				<rdf:li rdf:resource="http://unshiu.drecom.jp/news/1"/>
    				<rdf:li rdf:resource="http://unshiu.drecom.jp/news/2"/>
    				<rdf:li rdf:resource="http://unshiu.drecom.jp/news/3"/>
    				<rdf:li rdf:resource="http://unshiu.drecom.jp/news/4"/>
    			</rdf:Seq>
    		</items>
    	</channel>
    	<image rdf:about="http://unshiu.drecom.jp/logo.gif">
    		<title>unshiu news</title>

    		<link>http://unshiu.drecom.jp</link>
    		<url>http://unshiu.drecom.jp/logo.gif</url>
    	</image>
    	<item rdf:about="http://unshiu.drecom.jp/news/1">
    		<title>[release][base]1.0.3</title>
    		<link>http://unshiu.drecom.jp/news/1</link>
    		<description>1.0.3をリリースしました</description>
    		<dc:date>2009-01-26T19:38:01+09:00</dc:date>
    	</item>
    	<item rdf:about="http://unshiu.drecom.jp/news/2">
    		<title>[release][base]1.1.0</title>
    		<link>http://unshiu.drecom.jp/news/2</link>
    		<description>1.1.0をリリースしました
    </description>
    		<dc:date>2009-01-26T19:38:01+09:00</dc:date>
    	</item>
    	
    	<item rdf:about="http://unshiu.drecom.jp/news/3">
    		<title>[release][abm]1.0.3</title>
    		<link>http://unshiu.drecom.jp/news/3</link>
    		<description>abm1.0.3をリリースしました
    </description>
    		<dc:date>2009-01-26T19:38:01+09:00</dc:date>
    	</item>
    	
    	<item rdf:about="http://unshiu.drecom.jp/news/4">
    		<title>お知らせ</title>
    		<link>http://unshiu.drecom.jp/news/4</link>
    		<description>お知らせ
    </description>
    		<dc:date>2009-01-26T19:38:01+09:00</dc:date>
    	</item>
    </rdf:RDF>
EOS
    
    BasePlugin.stubs(:rss).returns(RSS::Parser.parse(response_sample))
    
    base_news = BasePlugin.news_by_name('base')
    
    assert_not_nil(base_news)
    assert_equal(base_news.size, 2)
    assert_equal(base_news[0].title, "[release][base]1.0.3")
  end
end