class ApplicationJob < ActiveJob::Base
  prepend AccountTenanted

  discard_on ActiveJob::DeserializationError
end
