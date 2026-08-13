class ErrorsController < ApplicationController
  allow_unauthenticated_access only: :not_found

  def not_found
    render :not_found, formats: :html, content_type: "text/html", status: :not_found
  end
end
