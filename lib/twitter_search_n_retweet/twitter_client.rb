module TwitterSearchNRetweet
  class TwitterClient
    def initialize
      @config = TwitterSearchNRetweet::Configuration.instance.twitter_config
      Twitter.configure do |twitter_config|
        %w(consumer_key consumer_secret oauth_token oauth_token_secret).each do |key|
          twitter_config.send(key + '=', @config[key])
        end
      end
    end

    def search(query_string)
      query_string << ' -rt' unless query_string =~ /\s-rt\s*$/
      Twitter.search(query_string, :rpp => 30, :lang => 'en', :result_type => 'recent')
    end
  end
end
