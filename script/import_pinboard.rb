#! /usr/bin/env ruby
require 'bundler/setup'
require 'json'
require 'time'
require_relative 'lib/bookmark'

puts "Importing bookmarks from #{ENV['IMPORT_FILE']}"
importfile = File.expand_path(ENV['IMPORT_FILE'])

data = JSON.parse File.read(importfile)

data.each do |item|
  bookmark = Bookmark.new(
    url: item['href'],
    title: item['description'],
    tags: item['tags'].split(' '),
    notes: item['extended'],
    created_at: Time.parse(item['time']),
  )
  bookmark.save
end
