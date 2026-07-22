xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title "buildlog"
    xml.description "A public build-log — what I build and learn, posted daily."
    xml.link root_url
    xml.language "en-us"

    @entries.each do |entry|
      xml.item do
        xml.title entry.created_at.strftime("%b %-d, %Y")
        xml.description entry.body
        xml.pubDate entry.created_at.to_fs(:rfc822)
        xml.link entry_url(entry)
        xml.guid entry_url(entry)
      end
    end
  end
end
