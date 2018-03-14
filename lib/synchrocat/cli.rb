require 'optparse'
require 'yaml'


module Synchrocat
  class CLI
    def self.process(args)
      # Handle command-line arguments
      options = {}

      opt_parser = OptionParser.new do |opt|
        opt.banner = "Usage: synchrocat [options] config.yml"
        opt.separator ""
        opt.separator "Options"

        opt.on("-h", "--help", "help") do
            puts opt_parser
            exit
        end
      end

      opt_parser.parse!(args)

      # Require config.yml
      if ARGV.length != 1
        puts opt_parser
        exit
      end

      config = YAML.load_file(ARGV[0])
      Synchrocat.process(config)
    end
  end
end
