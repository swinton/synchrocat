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

        opt.on("-b", "--branch=val", "name of branch to create on destination repos") do |branch|
          options[:branch] = branch
        end
      end

      opt_parser.parse!(args)

      # Require config.yml
      if ARGV.length == 0
        puts opt_parser
        exit
      end

      config = YAML.load_file(ARGV[-1])
      Synchrocat.process(config, options)
    end
  end
end
