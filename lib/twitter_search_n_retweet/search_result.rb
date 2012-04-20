module TwitterSearchNRetweet
  # Record a search result
  class SearchResult
    include DataMapper::Resource
  
    property :id, Serial
    property :created_at, DateTime

    property :from_user, String, :required => true
    property :from_user_id, String, :required => true
    property :twitter_id, String, :required => true
    property :text, String, :length => 255

    belongs_to :search
  end
end
