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

    def exclude_strings; @config['exclude_strings']; end
    def search_terms; @config['search_terms']; end

    def search(query_string)
      query_string << ' -rt' unless query_string =~ /\s-rt\s*$/
      Twitter.search(query_string, :rpp => 30, :include_entities => false, :lang => 'en', :result_type => 'recent')
    end

    def result_passes_criteria?(result)
      exclude_strings.each do |exclude_string|
        return false if result.text =~ /#{exclude_string}/i
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
