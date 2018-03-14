require 'base64'
require 'octokit'

require_relative 'synchrocat/cli'

module Synchrocat

  class << self
    def process(configuration)
      # Validate the configuration
      raise 'Invalid configuration' unless self.validate(configuration)

      # Pull down the source repo latest
      source = self.octokit.contents(configuration['source']['repo'], :path => configuration['source']['path'])

      # Make sure we have an array of files, even if a single file was specified
      source = [source] unless source.kind_of?(Array)

      # Make sure we have the contents of each file in source
      source.map! do |s|
        if s.content.nil?
          s = self.octokit.contents(configuration['source']['repo'], :path => s.path)
        end
        s
      end

      # Synch across destination repos
      configuration['destinations'].each do |destination|
        # Fetch master
        master = self.octokit.ref(destination['repo'], 'heads/master')

        # Branch off master
        branch = self.octokit.create_ref(destination['repo'],
          "heads/branch/synchrocat/#{Time.now.to_i}",
          master.object.sha)

        # Fetch tree, recursively
        tree = self.octokit.tree(destination['repo'], master.object.sha, :recursive => true)
        tree = tree.tree

        # Update each file from source
        source.each do |file|
          # Look for existing file in tree
          existing = tree.select { |t| t.path == "#{destination['path']}/#{file.name}" }

          if existing.empty?
            # Not found, create file on destination repo
            self.octokit.create_contents(
              destination['repo'], # repo
              "#{destination['path']}/#{file.name}", # path
              "Create #{destination['path']}/#{file.name}", # message
              Base64.decode64(file.content), # contents
              :branch => branch.ref # branch
            )
          else
            # Found, update file on destination repo
            existing = existing[0]
            self.octokit.update_contents(
              destination['repo'], # repo
              existing.path, # path
              "Update #{existing.path}", # message
              existing.sha, # blob sha
              Base64.decode64(file.content), # contents
              :branch => branch.ref # branch
            )
          end
        end
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
