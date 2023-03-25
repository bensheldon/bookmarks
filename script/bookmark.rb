#! /usr/bin/env ruby
require 'bundler/setup'

require 'optparse'
require 'octokit'
require_relative 'lib/bookmark'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: bookmark.rb [options]"

  opts.on("--url BOOKMARK_URL", String)
  opts.on("--title [BOOKMARK_TITLE]", String)
  opts.on("--tags [BOOKMARK_TAGS]", String)
  opts.on("--notes [BOOKMARK_NOTES]", String)
  opts.on("--commit [REPOSITORY#BRANCH]", String)
  opts.on("--save")
end.parse!(into: options)

options[:url] ||= ENV['BOOKMARK_URL']
raise ArgumentError, "--url BOOKMARK_URL is required" unless options[:url]

options[:url] = options[:url].strip

options[:title] ||= ENV['BOOKMARK_TITLE']
options[:title] = options[:title]&.strip

options[:tags] ||= ENV['BOOKMARK_TAGS']
options[:tags] = Array(options[:tags]&.split(",")&.map(&:strip))

if $stdin.stat.pipe?
  options[:notes] ||= $stdin.read
end
options[:notes] ||= ENV['BOOKMARK_NOTES']

bookmark = Bookmark.new(url: options[:url], title: options[:title], notes: options[:notes], tags: options[:tags])
puts bookmark.to_s

puts "\n\n\========================\n\n"

if options[:save]
  bookmark.save
  puts "Saved to #{bookmark.filepath}"
end

if options[:commit]
  require 'octokit'
  raise "GITHUB_TOKEN is required" unless ENV['GITHUB_TOKEN']
  github = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
  repo, branch = options[:commit].strip.split("#")

  raise ArgumentError, "--commit argument is missing value in form of: 'user/repo#branch' " unless repo && branch

  # Use the GitHub API to create a new commit
  result = github.create_contents(
    repo,
    bookmark.filepath,
    "Add bookmark for #{bookmark.url}",
    bookmark.to_s,
    branch: branch
  )

  puts "Committed to #{result.content.html_url}"
end
