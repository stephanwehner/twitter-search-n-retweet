require 'yaml'

module TwitterSearchNRetweet
  class Configuration
    def initialize
      @config = YAML.load(IO.read(TwitterSearchNRetweet_ConfigFilePath))[ENV['TSNR_ENV']]
    end
    def datamapper_path
     @config['database'] # 'sqlite:///tmp/db.sqlite'
    end
  end
end
