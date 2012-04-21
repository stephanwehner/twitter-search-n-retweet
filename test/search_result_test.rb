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

  def test_to_retweet
    search_result = TwitterSearchNRetweet::SearchResult.new(:from_user => '123name', :text => 'big test tweet')
    assert_equal 'RT @123name big test tweet -- GOOD ONE', search_result.to_retweet('GOOD ONE')
    assert_equal 'RT @123name big test tweet', search_result.to_retweet('')
  end


  def test_post_retweet
    search = TwitterSearchNRetweet::Search.create(:query_string => 'abc')
    search_result = TwitterSearchNRetweet::SearchResult.create(mock_search_result(:search => search, :from_user => '123name', :text => 'big test tweet'))
    Twitter.expects(:update).returns(OpenStruct.new(:id => 987654321012345678))
    assert_nil search_result.retweet_id
    search_result.post_retweet('')
    assert_equal 987654321012345678, search_result.retweet_id
  end
end
