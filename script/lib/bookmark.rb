require 'yaml'
require 'securerandom'
require 'time'
class Bookmark
  attr_accessor :url, :title, :tags, :notes, :created_at, :id

  def self.load_all
    Dir.glob("_bookmarks/*.md").map do |path|
      load(path)
    end
  end

  def self.load(path)
    id = File.basename(path, ".md").split("_")[1]
    content = YAML.load_file(path)
    new(
      url: content["url"],
      title: content["title"],
      tags: content["tags"],
      notes: content["notes"],
      created_at: Time.parse(content["created_at"]),
      id: id,
    )
  end

  def initialize(url:, title: nil, tags: nil, notes: nil, created_at: nil, id: nil)
    @url = url
    @title = title
    @tags = tags
    @notes = notes
    @created_at = created_at || Time.new
    @id = id || SecureRandom.uuid
  end

  def save
    File.write(filepath, to_s)
  end

  def filepath
    "_bookmarks/#{filename}"
  end

  def filename
    "#{created_at.strftime('%Y-%m-%d')}_#{id}.md"
  end

  def to_s
    frontmatter = {
      url: url,
      created_at: Time.new.strftime('%Y-%m-%d %H:%M %Z'),
      title: title,
      tags: tags,
    }.transform_keys(&:to_s)

    <<~MARKDOWN
      #{frontmatter.to_yaml.strip}
      ---
      
      #{notes&.strip}
    MARKDOWN
  end
end
