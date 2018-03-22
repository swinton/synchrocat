require 'base64'
require 'octokit'

require_relative 'synchrocat/cli'

module Synchrocat

  class << self
    def process(configuration, opts={})
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
        puts "Syncing with #{destination['repo']}..."

        # Fetch master
        master = self.octokit.ref(destination['repo'], 'heads/master')

        # Branch off master
        branch = self.octokit.create_ref(destination['repo'],
          "heads/" + (opts[:branch] || "synchrocat/#{Time.now.to_i}"),
          master.object.sha)

        # Fetch tree, recursively
        tree = self.octokit.tree(destination['repo'], master.object.sha, :recursive => true)
        tree = tree.tree

        # Update each file from source
        source.each do |file|
          print "#{file.name}..."
          # Construct destination path
          path = self.destination_path(destination['path'], file.name)

          # Look for existing path in destination tree
          existing = tree.select { |t| t.path == path }

          if existing.empty?
            # Not found, create file on destination repo
            self.octokit.create_contents(
              destination['repo'], # repo
              path, # path
              "Create #{path}", # message
              Base64.decode64(file.content), # contents
              :branch => branch.ref # branch
            )
          else
            # Found, update file on destination repo
            existing = existing[0]
            self.octokit.update_contents(
              destination['repo'], # repo
              path, # path
              "Update #{path}", # message
              existing.sha, # blob sha
              Base64.decode64(file.content), # contents
              :branch => branch.ref # branch
            )
          end
          print " ✔\n"
          STDOUT.flush
        end
      end
    end

    def octokit
      # Let's auto-paginate
      Octokit.auto_paginate = true

      return @octokit if defined?(@octokit)

      @octokit = Octokit::Client.new(:netrc => true)
    end

    def destination_path(dest, file_name)
      # dest may be nil, cast to String, remove trailing slash
      path = dest.to_s.chomp('/')

      # join with '/', unless we're just saving in the root
      path += '/' unless path.length == 0

      # join with file_name
      path += file_name
    end

    def validate(configuration)
      # TODO
      true
    end

  end

end
