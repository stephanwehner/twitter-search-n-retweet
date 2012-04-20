unless defined?(TwitterSearchNRetweet_ConfigFilePath)
  TwitterSearchNRetweet_ConfigFilePath = File.expand_path('../test_config.yaml', __FILE__) 
end
ENV['TSNR_ENV'] ||= 'test'

require 'minitest/autorun'
require File.expand_path('../../lib/twitter_search_n_retweet/base', __FILE__)
