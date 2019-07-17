module Jets::Router::Resources
  class Filter < Base
    def pass?(action)
      return true unless @options[:only]
      only = [@options[:only]].flatten.map(&:to_s)
      only.include?(action.to_s)
      # except
    end
  end
end
