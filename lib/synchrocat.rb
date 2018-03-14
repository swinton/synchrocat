require 'octokit'

require_relative 'synchrocat/cli'

module Synchrocat

  class << self
    def process(configuration)
      # Validate the configuration
      raise 'Invalid configuration' unless self.validate(configuration)

      # Pull down the source repo latest
      # puts "source: #{configuration['source']}"
      puts self.octokit.contents(configuration['source']['repo'], :path => configuration['source']['path'])

      # Synch across destination repos
      configuration['destinations'].each do |destination|
        puts "#{destination}"
      end
    end

    def octokit
      # Let's auto-paginate
      Octokit.auto_paginate = true

      return @octokit if defined?(@octokit)

      @octokit = Octokit::Client.new(:netrc => true)
    end

    def validate(configuration)
      # TODO
      true
    end

  end

end
