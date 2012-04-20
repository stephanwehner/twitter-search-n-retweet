module TwitterSearchNRetweet
  class Search
    # Record when searches are performed in order to
    # be able to control the load on Twitter servers
  
    include DataMapper::Resource
  
    property :id, Serial
    property :created_at, DateTime
    property :query_string, String, :required => true, :length => 255

  end
end
