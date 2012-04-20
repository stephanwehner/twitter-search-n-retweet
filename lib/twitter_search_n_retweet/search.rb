module TwitterSearchNRetweet
  # Record when searches are performed in order to
  # be able to control the load on Twitter servers
  class Search
  
    include DataMapper::Resource
  
    property :id, Serial
    property :created_at, DateTime
    property :query_string, String, :required => true, :length => 255

    has n, :search_results
  end
end
