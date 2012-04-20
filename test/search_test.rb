require File.expand_path('../test_helper', __FILE__)

class SearchTest < MiniTest::Unit::TestCase
  def test_can_create
    Search.create(:query_string => 'q')
  end
end
