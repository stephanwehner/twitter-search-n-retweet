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

    def exclude_strings_strict; @config['exclude_strings_strict']; end
    def exclude_words; @config['exclude_words']; end
    def search_terms; @config['search_terms']; end
    def account_name; @config['account_name']; end
    def retweet_ending; @config['retweet_ending']; end
    def max_tweet_length; @config['max_tweet_length'].to_i; end
    def min_tweet_length; @config['min_tweet_length'].to_i; end

    def search(query_string)
      query_string << ' -rt' unless query_string =~ /\s-rt\s*$/
      Twitter.search(query_string, :rpp => 30, :include_entities => false, :lang => 'en', :result_type => 'recent')
    end

    def result_passes_criteria?(result)
      text = result.text
      return false if text.nil?
      text.strip!
      return false if text.strip == ''
      return false if text =~ /^\s*@/
      return false if text =~ /^RT /
      return false if text =~ / RT /
      return false if text.length > max_tweet_length
      return false if text.length < min_tweet_length
      return false if text =~ /#{account_name}/
      exclude_strings_strict.each do |exclude_string|
        return false if result.text =~ /#{exclude_string}/i
      end
      exclude_words.each do |word|
        return false if result.text =~ /\b#{word}\b/i
      end
      true
    end

    def update_search(search_term)
      results = search(search_term)
      return if results.length == 0
      search = TwitterSearchNRetweet::Search.new(:query_string => search_term)
      return unless search.valid? # logging ?
      results.collect { |result| result if result_passes_criteria?(result) }.compact.each do |result|
        search.search_results << SearchResult.new(:from_user => result.from_user,
                                                  :from_user_id => result.from_user_id_str,
                                                  :twitter_id => result.id_str,
                                                  :text => result.text)
      end
      search.save
    end

    def update_searches
      search_terms.each do |search_term|
        update_search(search_term)
      end
    end
  end
end
