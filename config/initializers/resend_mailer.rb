# Deliver mail through Resend's HTTP API instead of SMTP.
#
# DigitalOcean blocks outbound SMTP ports (587/465) by default on new
# droplets, so ActionMailer's built-in :smtp delivery method can't reach
# any mail provider. Resend's API runs over HTTPS (443), which is open.
class ResendDeliveryMethod
  def initialize(_settings)
  end

  def deliver!(mail)
    Resend.api_key = Rails.application.credentials.dig(:smtp, :password)

    Resend::Emails.send({
      from: mail[:from].to_s,
      to: Array(mail[:to]&.to_s),
      cc: Array(mail[:cc]&.to_s),
      bcc: Array(mail[:bcc]&.to_s),
      subject: mail.subject,
      html: html_part(mail),
      text: text_part(mail)
    })
  end

  private

  def html_part(mail)
    return mail.body.decoded if mail.content_type&.start_with?("text/html")

    mail.html_part&.decoded
  end

  def text_part(mail)
    return mail.body.decoded if mail.content_type&.start_with?("text/plain")

    mail.text_part&.decoded
  end
end

ActionMailer::Base.add_delivery_method :resend, ResendDeliveryMethod
