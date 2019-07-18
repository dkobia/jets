module Jets::Router::Resources
  class Options < Base
    def build(action)
      controller = @options[:singular_resource] ? @name.to_s.pluralize : @name
      options = @options.merge(to: "#{controller}##{action}")
      # remove special options from getting to create_route. For some reason .slice! doesnt work
      options.delete(:only)
      options.delete(:except)
      options
    end
  end
end
