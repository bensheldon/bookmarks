#! /usr/bin/env ruby
require 'bundler/setup'

require 'optparse'
require 'octokit'
require_relative 'lib/bookmark'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("--url URL", String) do |value|
    options[:url] = value
  end
  options[:url] ||= ENV['BOOKMARK_URL']
  options[:url] = options[:url].strip

  opts.on("--title TITLE", String) do |value|
    options[:title] = value
  end
  options[:title] ||= ENV['BOOKMARK_TITLE']
  options[:title] = options[:title]&.strip

  opts.on("--tags TAGS", String) do |value|
    options[:tags] = value
  end
  options[:tags] ||= ENV['BOOKMARK_TAGS']
  options[:tags] = Array(options[:tags]&.split(",")&.map(&:strip))

  opts.on("--notes [NOTES]", String) do |value|
    options[:notes] = value
  end
  options[:notes] ||= ARGV.join
  options[:notes] = options[:notes]&.strip

  opts.on("--commit [REPOSITORY]", String) do |value|
    options[:commit] = value&.strip
  end

  opts.on("--save") do |value|
    options[:save] = value
  end
end.parse!

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
