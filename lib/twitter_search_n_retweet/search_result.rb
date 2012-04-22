module TwitterSearchNRetweet
  # Record a search result
  class SearchResult
    include DataMapper::Resource
  
    property :id, Serial
    property :created_at, DateTime

    property :from_user, String, :required => true
    property :from_user_id, String, :required => true
    property :twitter_id, String, :required => true, :unique => true
    property :text, String, :length => 255

    property :retweet_user_id, String, :unique => true
    property :retweet_id , Integer

    belongs_to :search

    def to_retweet(ending = '')
      t = "RT @#{from_user} #{text}"
      t << " -- #{ending}" unless ending.empty?
      t
    end

    # Successful if retweed_id set.
    def post_retweet(ending = '')
      self.retweet_user_id = from_user_id
      return unless valid?
      twitter_update = Twitter.update(to_retweet(ending), :in_reply_to_status_id => self.twitter_id)
      self.retweet_id = twitter_update.id
      self.save
    end

    def retweeted?
      !self.retweet_id.nil?
    end
  end
end
