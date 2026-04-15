# Tell crawlers like Googlebot to drop pages entirely from search results, even
# if other sites link to it
module BlockSearchEngineIndexing
  extend ActiveSupport::Concern

  included do
    after_action :block_search_engine_indexing
  end

  class_methods do
    def allow_search_engine_indexing(**options)
      skip_after_action :block_search_engine_indexing, **options
    end
  end

  private
    def block_search_engine_indexing
      headers["X-Robots-Tag"] = "none"
    end
end
