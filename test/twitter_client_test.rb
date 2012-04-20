require File.expand_path('../test_helper', __FILE__)

class TwitterClientTest < MiniTest::Unit::TestCase
  def setup
    reset_database!
  end

  def test_can_search
    tc = TwitterSearchNRetweet::TwitterClient.new
    Twitter.expects(:search).returns('abc result')
    sr = tc.search('abc')
    assert_equal 'abc result', sr
  end

  def test_search_options
    tc = TwitterSearchNRetweet::TwitterClient.new
    Twitter.expects(:search).with('abc -rt', :include_entities => false, :rpp => 30, :lang => 'en', :result_type => 'recent')
    tc.search('abc')
  end

  def test_update_search
    Twitter.expects(:search).returns([twitter_search_result(:text => 'abc 123'),
                                      twitter_search_result(:text => 'abc def 345'),
                                      twitter_search_result(:text => 'ghi 456')])
    tc = TwitterSearchNRetweet::TwitterClient.new
    tc.update_search('abc')
    assert_equal 1, TwitterSearchNRetweet::Search.count
    assert_equal 'abc -rt', TwitterSearchNRetweet::Search.last.query_string
    assert_equal 2, TwitterSearchNRetweet::SearchResult.count
    assert_equal ['abc 123', 'ghi 456'], TwitterSearchNRetweet::SearchResult.all.collect { |sr| sr.text}.sort
  end

  def test_update_search_only_excluded_matches
    Twitter.expects(:search).returns([twitter_search_result(:text => 'abc def'),
                                      twitter_search_result(:text => 'abc def 345'),
                                      twitter_search_result(:text => 'ghi def')])
    tc = TwitterSearchNRetweet::TwitterClient.new
    tc.update_search('abc')
    assert_equal 1, TwitterSearchNRetweet::Search.count
    assert_equal 0, TwitterSearchNRetweet::SearchResult.count
  end

  def test_update_search_no_matches
    Twitter.expects(:search).returns([])
    tc = TwitterSearchNRetweet::TwitterClient.new
    tc.update_search('abc')
    assert_equal 0, TwitterSearchNRetweet::Search.count
    assert_equal 0, TwitterSearchNRetweet::SearchResult.count
  end
  def test_update_searches
    tc = TwitterSearchNRetweet::TwitterClient.new
    tc.expects(:update_search).with('abc') # from test_config.yaml
    tc.expects(:update_search).with('ghi')
    tc.update_searches
  end
end
