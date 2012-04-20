require File.expand_path('../test_helper', __FILE__)

class SearchResultTest < MiniTest::Unit::TestCase
  def test_can_create
    search = TwitterSearchNRetweet::Search.new(:query_string => 'abc')
    assert search.save, search.errors.full_messages.inspect
    search_result = TwitterSearchNRetweet::SearchResult.new(:search => search,
                                                            :from_user => '123456user',
                                                            :from_user_id => '123456',
                                                            :twitter_id => '1234567890',
                                                            :text => 'test tweet')
    assert search_result.valid?, search_result.errors.full_messages.inspect
    assert search_result.save, search_result.errors.full_messages.inspect
    assert_equal 'test tweet', TwitterSearchNRetweet::SearchResult.last.text
  end


end
