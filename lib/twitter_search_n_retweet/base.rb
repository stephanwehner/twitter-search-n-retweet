require 'dm-sqlite-adapter'
require 'data_mapper'

%w( search ).each do |file|
  require File.expand_path("../#{file}", __FILE__)
end

DataMapper.setup(:default, 'sqlite:///tmp/db.sqlite')

DataMapper.auto_migrate!
DataMapper.finalize
