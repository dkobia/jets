module Jets::Router::Resources
  class Options < Base
    def build(action)
      controller = @options[:singular_resource] ? @name.to_s.pluralize : @name
      @options.merge(to: "#{controller}##{action}")
    end
  end
end
