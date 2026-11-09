# Compatibility for Fizzy's route declarations without its private logging gem.
module FilterPathParameters
  def filter_path_parameters(*parameters, &block)
    scope defaults: { filtered_path_parameters: parameters }, &block
  end
end

ActionDispatch::Routing::Mapper.include FilterPathParameters

module FilteredRequestPath
  def parameter_filter
    ActiveSupport::ParameterFilter.new(Array(get_header("action_dispatch.parameter_filter")) + Array(path_parameters[:filtered_path_parameters]))
  end

  def filtered_path
    CredentialPathFilter.filter_path(super)
  end
end

ActionDispatch::Request.prepend FilteredRequestPath

module FilteredRedirectPath
  def filtered_location
    CredentialPathFilter.filter_url(super)
  end
end

ActionDispatch::Response.prepend FilteredRedirectPath
