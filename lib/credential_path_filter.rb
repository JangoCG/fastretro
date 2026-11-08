module CredentialPathFilter
  extend self

  def filter_path(path)
    path, query = path.to_s.split("?", 2)
    prefix = path[AccountSlug::PATH_INFO_MATCH].to_s
    unscoped_path = path.delete_prefix(prefix)

    Rails.application.routes.routes.each do |route|
      if (parameters = route.defaults[:filtered_path_parameters]) && (parameters.map(&:to_s) & route.path.names).any?
        pattern = Regexp.new(route.path.to_regexp.source.sub(/\\[Zz]\z/, "(?=/|\\z)"))
        if match = pattern.match(unscoped_path)
          route.path.names.each_with_index.reverse_each do |name, index|
            if parameters.map(&:to_s).include?(name) && match.begin(index + 1)
              unscoped_path[match.begin(index + 1)...match.end(index + 1)] = "[FILTERED]"
            end
          end
          break
        end
      end
    end

    [ prefix + unscoped_path, query ].compact.join("?")
  end

  def filter_url(url)
    uri = URI.parse(url)
    # URI#path= rejects the brackets in [FILTERED]; preserve the original URL's encoding.
    url.sub(uri.path, filter_path(uri.path))
  rescue URI::InvalidURIError
    "[FILTERED]"
  end
end
