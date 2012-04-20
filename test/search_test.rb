require File.expand_path('../test_helper', __FILE__)

class SearchTest < MiniTest::Unit::TestCase
  def test_can_create
    assert TwitterSearchNRetweet::Search.create(:query_string => 'q test')
    assert_equal 'q test', TwitterSearchNRetweet::Search.last.query_string
  end

  def test_query_string_required
    assert !TwitterSearchNRetweet::Search.new.valid?
    assert !TwitterSearchNRetweet::Search.new(:query_string => '').valid?
  end

  def test_query_string_length
    assert !TwitterSearchNRetweet::Search.new(:query_string => 'x' * 256).valid?
    assert TwitterSearchNRetweet::Search.new(:query_string => 'x' * 255).valid?
  end
end
