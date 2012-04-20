require 'bundler'
Bundler.require

%w( configuration
    search ).each do |file|
  require File.expand_path("../#{file}", __FILE__)
end

# Set TwitterSearchNRetweet_ConfigFilePath 

config = TwitterSearchNRetweet::Configuration.new

DataMapper.setup(:default, config.datamapper_path)

DataMapper.auto_migrate!
DataMapper.finalize
