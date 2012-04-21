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

    property :retweet_id , Integer

    belongs_to :search

    def to_retweet(ending = '')
      t = "RT @#{from_user} #{text}"
      t << " -- #{ending}" unless ending.empty?
      t
    end

    def post_retweet(ending = '')
      twitter_update = Twitter.update(to_retweet(ending))
      self.update(:retweet_id => twitter_update.id)
    end
  end
end
