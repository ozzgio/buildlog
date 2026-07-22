class ApplicationMailer < ActionMailer::Base
  # Resend sandbox sender (no domain verification needed) — this app has a
  # single user, so there's no need to verify ozzo.blog for sending yet.
  default from: "onboarding@resend.dev"
  layout "mailer"
end
