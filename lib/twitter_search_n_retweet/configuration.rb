require 'yaml'

module TwitterSearchNRetweet
  class Configuration
    

    def development?; @env == 'development'; end
    def test?; @env == 'test'; end
    def production?; @env == 'production'; end

    def datamapper_config
     @config['database']
    end

    def twitter_config
     @config['twitter']
    end

    def self.instance
      @instance ||= self.new
    end

    private

    def initialize
      @env = ENV['TSNR_ENV'] || 'development'
      @config = YAML.load(IO.read(TwitterSearchNRetweet_ConfigFilePath))[@env]
    end
  end
end
