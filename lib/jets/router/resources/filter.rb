module Jets::Router::Resources
  class Filter < Base
    def yes?(action)
      return true unless @options[:only]
      only = [@options[:only]].flatten.map(&:to_s)
      only.include?(action.to_s)
      # except
    end
  end
end
