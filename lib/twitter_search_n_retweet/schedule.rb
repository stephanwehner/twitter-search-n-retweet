class Search
  # Record when searches are performed in order to
  # be able to control the load on Twitter servers

  include DataMapper::Resource

  property :id, Serial
  property :created_at, Integer
  property :query_string, String
end
