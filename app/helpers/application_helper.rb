module ApplicationHelper
  def entry_timestamp(entry)
    entry.created_at.strftime("%A, %b %-d, %Y - %-I:%M %p")
  end

  def entry_day_label(entry)
    entry.created_at.strftime("%b %-d")
  end

  def entry_link_label(link)
    URI.parse(link).host&.delete_prefix("www.") || link
  rescue URI::InvalidURIError
    link
  end

  def safe_external_url(link)
    uri = URI.parse(link.to_s)
    return unless uri.is_a?(URI::HTTP) && uri.host.present?

    uri.to_s
  rescue URI::InvalidURIError
    nil
  end

  def buildlog_feedback_url
    safe_external_url(ENV["BUILDLOG_FEEDBACK_URL"])
  end

  def buildlog_github_issues_url
    "https://github.com/ozzgio/buildlog/issues"
  end
end
