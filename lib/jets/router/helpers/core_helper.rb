module Jets::Router::Helpers
  module CoreHelper
    # Used for form_for helper
    def polymorphic_path(record, _)
      url_for(record)
    end

    def session
      @_jets[:controller].session
    end
  end
end
