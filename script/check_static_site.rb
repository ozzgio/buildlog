#!/usr/bin/env ruby
require "yaml"
require "time"
require "uri"
require "rexml/document"

output = ARGV.fetch(0, "_site")
entries = Dir.glob("site/_entries/*.md").map do |path|
  frontmatter, body = File.read(path).split(/^---\s*$\n/, 3).drop(1)
  metadata = YAML.safe_load(frontmatter)
  permalink = metadata.fetch("permalink")
  abort "Invalid entry URL: #{path}" unless permalink.match?(%r{\A/entries/[1-9]\d*/\z})
  Time.iso8601(metadata.fetch("date"))
  abort "Empty entry: #{path}" if body.to_s.strip.empty?
  if metadata["link"]
    link = URI.parse(metadata["link"])
    abort "Invalid reference link: #{path}" unless link.is_a?(URI::HTTP) && link.host
  end
  page = "#{output}#{permalink}index.html"
  abort "Missing entry page: #{permalink}" unless File.file?(page)
  abort "Entry page lost its date: #{permalink}" unless File.read(page).include?(metadata.fetch("date").split("T").first)
  metadata
end
abort "No entries" if entries.empty?
abort "Duplicate entry URLs" unless entries.map { |entry| entry["permalink"] }.uniq.size == entries.size

feed = REXML::Document.new(File.read("#{output}/feed.xml"))
items = REXML::XPath.match(feed, "/rss/channel/item")
expected = entries.sort_by { |entry| Time.iso8601(entry["date"]) }.reverse.first(50)
actual = items.map { |item| item.elements["guid"].text }
abort "RSS order or durable URLs changed" unless actual == expected.map { |entry| "https://log.ozzo.blog#{entry['permalink'].delete_suffix("/")}" }
abort "Legacy RSS differs" unless File.binread("#{output}/feed") == File.binread("#{output}/feed.xml")
abort "Feedback form missing" unless File.read("#{output}/feedback/index.html").include?("https://tally.so/embed/QKa62p")
abort "Styles missing" unless File.size?("#{output}/assets/style.css")
abort "Legacy author login remains" if File.read("#{output}/index.html").include?("/session/new")
puts "Static site verified: #{entries.size} entry pages, ordered RSS with original URLs, legacy /feed, feedback and CSS."
