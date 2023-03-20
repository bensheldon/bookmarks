#! /usr/bin/env ruby
require 'bundler/setup'

require 'optparse'
require 'octokit'
require_relative 'lib/bookmark'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("--url URL", String) do |value|
    options[:url] = value.strip
  end
  opts.on("--title TITLE", String) do |value|
    options[:title] = value.strip
  end
  opts.on("--tags TAGS", String) do |value|
    options[:tags] = value.split(",").map(&:strip)
  end
  opts.on("--notes [NOTES]", String) do |value|
    options[:notes] = value.strip
  end
  opts.on("--commit [REPOSITORY]", String) do |value|
    options[:commit] = value
  end
  opts.on("--save") do |value|
    options[:save] = value
  end
end.parse!

options[:notes] ||= ARGV.join.strip

bookmark = Bookmark.new(url: options[:url], title: options[:title], notes: options[:notes], tags: options[:tags])
puts bookmark.to_s

bookmark.save if options[:save]

if options[:commit]
  require 'octokit'
  raise "GITHUB_TOKEN is required" unless ENV['GITHUB_TOKEN']
  github = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  repo, branch = options[:commit].split("#")

  # Use the GitHub API to create a new commit
  result = github.create_contents(
    repo,
    bookmark.filepath,
    "Add bookmark for #{bookmark.title}",
    bookmark.to_s,
    branch: branch
  )

  puts "==================\n\n Created #{result.content.html_url}"
end
