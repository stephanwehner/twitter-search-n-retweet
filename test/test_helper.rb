unless defined?(TwitterSearchNRetweet_ConfigFilePath)
  TwitterSearchNRetweet_ConfigFilePath = File.expand_path('../../config/twitter_search_n_retweet.yaml', __FILE__) 
end
ENV['TSNR_ENV'] ||= 'test'

require 'minitest/autorun'
require File.expand_path('../../lib/twitter_search_n_retweet/base', __FILE__)
