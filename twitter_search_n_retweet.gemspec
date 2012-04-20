# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "twitter_search_n_retweet/version"

Gem::Specification.new do |s|
  s.name        = "twitter_search_n_retweet"
  s.version     = TwitterSearchNRetweet::VERSION
  s.date        =  TwitterSearchNRetweet::DATE
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Stephan Wehner"]
  s.email       = ["stephanwehner@gmail.com"]
  s.homepage    = "http://stephan.sugarmotor.org"
  s.summary     = %q{Twitter Search and  Retweet}
  s.description = %q{Search twitter for keywords, filter, massage, and retweet}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")

  s.require_paths = ["lib"]
end
