require File.expand_path('../test_helper', __FILE__)

class TwitterClientTest < MiniTest::Unit::TestCase
  def test_can_search
    tc = TwitterSearchNRetweet::TwitterClient.new
    Twitter.expects(:search).returns('abc result')
    sr = tc.search('abc')
    assert_equal 'abc result', sr
  end

  def test_search_options
    tc = TwitterSearchNRetweet::TwitterClient.new
    Twitter.expects(:search).with('abc -rt', :rpp => 30, :lang => 'en', :result_type => 'recent')
    tc.search('abc')
  end
end
