require 'bundler'
Bundler.require

%w( configuration
    search
    search_result
    twitter_client).each do |file|
  require File.expand_path("../#{file}", __FILE__)
end

config = TwitterSearchNRetweet::Configuration.instance

DataMapper.setup(:default, config.datamapper_config)
DataMapper.auto_migrate!
DataMapper.finalize
