require 'yaml'
require 'securerandom'
require 'time'

class Bookmark
  attr_accessor :url, :title, :tags, :notes, :created_at, :published, :id

  def self.load_all
    Dir.glob("_bookmarks/*.md").map do |path|
      load(path)
    end.sort_by(&:created_at)
  end

  def self.load(path)
    id = File.basename(path, ".md").split("_")[1]

    contents = File.read(path)
    documents = contents.split("---").map(&:strip).reject(&:empty?)
    frontmatter = YAML.safe_load(documents[0] || "")
    body = documents[1] || ""

    new(
      url: frontmatter["url"],
      title: frontmatter["title"],
      tags: frontmatter["tags"],
      notes: body,
      created_at: Time.parse(frontmatter["created_at"]),
      published: frontmatter["published"],
      id: id,
    )
  end

  def initialize(url:, title: nil, tags: nil, notes: nil, created_at: nil, published: false, id: nil)
    @url = url
    @title = title
    @tags = tags
    @notes = notes
    @created_at = created_at || Time.new
    @published = published
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
      created_at: created_at.strftime('%Y-%m-%d %H:%M %Z'),
      published: published,
      title: title,
      tags: tags,
    }.transform_keys(&:to_s)
    body = notes&.strip

    <<~MARKDOWN
      #{frontmatter.to_yaml.strip}
      ---
      
      #{body}
    MARKDOWN
  end
end
