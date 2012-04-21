require File.expand_path('../test_helper', __FILE__)

class TwitterClientTest < MiniTest::Unit::TestCase

  # Many settings come from test/test_config.yaml
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

  def test_result_passes_criteria_empty
    tc = TwitterSearchNRetweet::TwitterClient.new
    
    assert !tc.result_passes_criteria?(twitter_search_result :text => '')
    assert !tc.result_passes_criteria?(twitter_search_result :text => ' ')
    assert !tc.result_passes_criteria?(twitter_search_result :text => ' ' * 10)
    assert !tc.result_passes_criteria?(twitter_search_result :text => "\n" * 10)
  end

  def test_result_passes_criteria_at
    tc = TwitterSearchNRetweet::TwitterClient.new
    
    assert !tc.result_passes_criteria?(twitter_search_result :text => '@someone hello')
    assert !tc.result_passes_criteria?(twitter_search_result :text => ' @someone hello')

    assert tc.result_passes_criteria?(twitter_search_result :text => ' hello @someone')
    assert tc.result_passes_criteria?(twitter_search_result :text => ' hello @someone else')
  end

  def test_result_passes_criteria_RT
    tc = TwitterSearchNRetweet::TwitterClient.new

    assert !tc.result_passes_criteria?(twitter_search_result :text => 'RT for fun')
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'RT @hello')
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'hello RT @mike')

    assert tc.result_passes_criteria?(twitter_search_result :text => 'Hello and RTSY GUTSY')
    assert tc.result_passes_criteria?(twitter_search_result :text => 'Hello and ARTSY')
    assert tc.result_passes_criteria?(twitter_search_result :text => 'Hello and RT')
    assert tc.result_passes_criteria?(twitter_search_result :text => 'RTY')
  end

  def test_result_passes_criteria_length
    tc = TwitterSearchNRetweet::TwitterClient.new

    assert !tc.result_passes_criteria?(twitter_search_result :text => 'x' * 121)
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'x')
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'ab')
    assert !tc.result_passes_criteria?(twitter_search_result :text => '        ab')
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'ab       ')

    assert tc.result_passes_criteria?(twitter_search_result :text => '1234')
    assert tc.result_passes_criteria?(twitter_search_result :text => 'x' * 120)
  end

  # Pretty strict!
  def test_result_passes_criteria_exclude_strings
    tc = TwitterSearchNRetweet::TwitterClient.new

    assert !tc.result_passes_criteria?(twitter_search_result :text => 'abc def')
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'abc Def')
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'DeF abc')
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'DeFwow')
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'wowceG')

    assert tc.result_passes_criteria?(twitter_search_result :text => 'cG b')
    assert tc.result_passes_criteria?(twitter_search_result :text => 'c ce')
    assert tc.result_passes_criteria?(twitter_search_result :text => 'wow there is de')
    assert tc.result_passes_criteria?(twitter_search_result :text => 'ef works')
  end

  def test_result_passes_criteria_exclude_words
    tc = TwitterSearchNRetweet::TwitterClient.new

    assert !tc.result_passes_criteria?(twitter_search_result :text => 'bingo')
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'Bingo')
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'i like bingo')
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'Go the bingo works')
    assert !tc.result_passes_criteria?(twitter_search_result :text => 'NOW BINGO!')

    assert tc.result_passes_criteria?(twitter_search_result :text => 'green bingohall')
    assert tc.result_passes_criteria?(twitter_search_result :text => 'going bingobingo')
    assert tc.result_passes_criteria?(twitter_search_result :text => 'raining and ingobingoing')
  end
end
