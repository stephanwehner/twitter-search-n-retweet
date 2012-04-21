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
    assert_equal 'abc', TwitterSearchNRetweet::Search.last.query_string
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

  def test_good_empty
    tc = TwitterSearchNRetweet::TwitterClient.new
    
    assert !tc.good?(twitter_search_result :text => '')
    assert !tc.good?(twitter_search_result :text => ' ')
    assert !tc.good?(twitter_search_result :text => ' ' * 10)
    assert !tc.good?(twitter_search_result :text => "\n" * 10)
  end

  def test_good_at
    tc = TwitterSearchNRetweet::TwitterClient.new
    
    assert !tc.good?(twitter_search_result :text => '@someone hello')
    assert !tc.good?(twitter_search_result :text => ' @someone hello')

    assert tc.good?(twitter_search_result :text => ' hello @someone')
    assert tc.good?(twitter_search_result :text => ' hello @someone else')
  end

  def test_good_RT
    tc = TwitterSearchNRetweet::TwitterClient.new

    assert !tc.good?(twitter_search_result :text => 'RT for fun')
    assert !tc.good?(twitter_search_result :text => 'RT @hello')
    assert !tc.good?(twitter_search_result :text => 'hello RT @mike')

    assert tc.good?(twitter_search_result :text => 'Hello and RTSY GUTSY')
    assert tc.good?(twitter_search_result :text => 'Hello and ARTSY')
    assert tc.good?(twitter_search_result :text => 'Hello and RT')
    assert tc.good?(twitter_search_result :text => 'RTY')
  end

  def test_good_length
    tc = TwitterSearchNRetweet::TwitterClient.new

    assert !tc.good?(twitter_search_result :text => 'x' * 121)
    assert !tc.good?(twitter_search_result :text => 'x')
    assert !tc.good?(twitter_search_result :text => 'ab')
    assert !tc.good?(twitter_search_result :text => '        ab')
    assert !tc.good?(twitter_search_result :text => 'ab       ')

    assert tc.good?(twitter_search_result :text => '1234')
    assert tc.good?(twitter_search_result :text => 'x' * 120)
  end

  # Pretty strict!
  def test_good_exclude_strings
    tc = TwitterSearchNRetweet::TwitterClient.new

    assert !tc.good?(twitter_search_result :text => 'abc def')
    assert !tc.good?(twitter_search_result :text => 'abc Def')
    assert !tc.good?(twitter_search_result :text => 'DeF abc')
    assert !tc.good?(twitter_search_result :text => 'DeFwow')
    assert !tc.good?(twitter_search_result :text => 'wowceG')

    assert tc.good?(twitter_search_result :text => 'cG b')
    assert tc.good?(twitter_search_result :text => 'c ce')
    assert tc.good?(twitter_search_result :text => 'wow there is de')
    assert tc.good?(twitter_search_result :text => 'ef works')
  end

  def test_good_exclude_strings_word_regexp
    tc = TwitterSearchNRetweet::TwitterClient.new
    assert !tc.good?(twitter_search_result :text => 'romabus')
    assert !tc.good?(twitter_search_result :text => 'romebus')
    assert tc.good?(twitter_search_result :text => 'romabuso')
    assert tc.good?(twitter_search_result :text => 'Qromabuso came')
    assert tc.good?(twitter_search_result :text => 'was a quackromebus')
  end

  def test_good_exclude_strings_strict_regexp
    tc = TwitterSearchNRetweet::TwitterClient.new
    assert !tc.good?(twitter_search_result :text => ' vaNcant b')
    assert !tc.good?(twitter_search_result :text => 'a vaecAnt')
    assert !tc.good?(twitter_search_result :text => 'vancanto')
    assert tc.good?(twitter_search_result :text => 'BBvaLcant')
  end

  def test_good_exclude_words
    tc = TwitterSearchNRetweet::TwitterClient.new

    assert !tc.good?(twitter_search_result :text => 'bingo')
    assert !tc.good?(twitter_search_result :text => 'Bingo')
    assert !tc.good?(twitter_search_result :text => 'i like bingo')
    assert !tc.good?(twitter_search_result :text => 'Go the bingo works')
    assert !tc.good?(twitter_search_result :text => 'NOW BINGO!')

    assert tc.good?(twitter_search_result :text => 'green bingohall')
    assert tc.good?(twitter_search_result :text => 'going bingobingo')
    assert tc.good?(twitter_search_result :text => 'raining and ingobingoing')
  end

  def test_post_search_result_no_search
    tc = TwitterSearchNRetweet::TwitterClient.new
    assert_nil tc.post_search_result('no search') 
  end

  def test_post_search_result_no_search_results
    tc = TwitterSearchNRetweet::TwitterClient.new
    TwitterSearchNRetweet::Search.create(:query_string => 'has no results')
    assert_nil tc.post_search_result('has no results') 
  end

  def test_post_search_result
    tc = TwitterSearchNRetweet::TwitterClient.new
    search = TwitterSearchNRetweet::Search.create(:query_string => 'has a result')
    search_result = TwitterSearchNRetweet::SearchResult.create(mock_search_result(:search => search))
    TwitterSearchNRetweet::SearchResult.any_instance.expects(:post_retweet)
    assert_equal search_result, tc.post_search_result('has a result') 
  end

  def test_post_search_result_already_retweeted
    tc = TwitterSearchNRetweet::TwitterClient.new
    search = TwitterSearchNRetweet::Search.create(:query_string => 'has a result')
    search_result = TwitterSearchNRetweet::SearchResult.create(mock_search_result(:search => search,
                                                                                  :retweet_id => '1234'))
    TwitterSearchNRetweet::SearchResult.any_instance.expects(:post_retweet).never
    assert_nil tc.post_search_result('has a result') 
  end
end
