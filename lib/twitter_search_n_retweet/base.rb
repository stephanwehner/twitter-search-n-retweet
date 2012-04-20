require 'dm-sqlite-adapter'
require 'data_mapper'

require File.expand_path('../schedule', __FILE__)

DataMapper.setup(:default, 'sqlite:///tmp/db.sqlite')

DataMapper.auto_migrate!
DataMapper.finalize
