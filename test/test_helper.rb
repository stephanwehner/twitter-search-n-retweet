unless defined?(TwitterSearchNRetweet_ConfigFilePath)
  TwitterSearchNRetweet_ConfigFilePath = File.expand_path('../test_config.yaml', __FILE__) 
end
ENV['TSNR_ENV'] ||= 'test'

require 'minitest/autorun'
require File.expand_path('../../lib/twitter_search_n_retweet/base', __FILE__)

class MiniTest::Unit::TestCase

  TWITTER_SEARCH_RESULT_TEMPLATE = {"created_at"=> Time.now,
                                    "from_user"=>"testdimension",
                                    "from_user_id"=>12345678,
                                    "from_user_id_str"=>"12345678",
                                    "from_user_name"=>"Test Dimension",
                                    "geo"=>nil,
                                    "id"=>123456789123456789,
                                    "id_str"=>"123456789123456789",
                                    "iso_language_code"=>"en",
                                    "metadata"=>{"result_type"=>"recent"},
                                    "profile_image_url"=>"http://a0.twimg.com/profile_images/1234567890/test_dimension_box_sml_normal.jpg",
                                    "profile_image_url_https"=>"https://a0.twimg.com/profile_images/1234567890/test_dimension_box_sml_normal.jpg",
                                    "source"=>"&lt;a href=&quot;http://twitterfeed.com&quot; rel=&quot;nofollow&quot;&gt;twitterfeed&lt;/a&gt;",
                                    "text"=>"Test news: Flipper denies test failures - ABC Online http://t.co/12345678",
                                    "to_user"=>nil,
                                    "to_user_id"=>nil,
                                    "to_user_id_str"=>nil,
                                    "to_user_name"=>nil}.freeze unless defined?(TWITTER_SEARCH_RESULT_TEMPLATE)
  def twitter_search_result(options = {})
    OpenStruct.new(TWITTER_SEARCH_RESULT_TEMPLATE.merge(options))
  end

  def reset_database!
    TwitterSearchNRetweet::SearchResult.all.destroy
    TwitterSearchNRetweet::Search.all.destroy
  end

end
