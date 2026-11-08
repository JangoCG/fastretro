# Rails 8.1 backport of Fizzy's header-only verification.
module RequestForgeryProtection
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :exception
    append_after_action :append_sec_fetch_site_to_vary_header
  end

  private
    def verified_request?
      request.get? || request.head? || !protect_against_forgery? ||
        (valid_request_origin? && verified_via_header_only?)
    end

    def verified_via_header_only?
      case sec_fetch_site_value
      when "same-origin", "same-site"
        true
      when nil
        !request.ssl? && !ActionDispatch::Http::URL.secure_protocol
      else
        false
      end
    end

    def sec_fetch_site_value
      if value = request.headers["Sec-Fetch-Site"]
        value.to_s.downcase.presence
      end
    end

    def append_sec_fetch_site_to_vary_header
      vary_header = response.headers["Vary"].to_s.split(",").map(&:strip).reject(&:blank?)
      unless vary_header.include?("Sec-Fetch-Site")
        response.headers["Vary"] = (vary_header + [ "Sec-Fetch-Site" ]).join(", ")
      end
    end
end
