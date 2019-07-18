class Jets::Router::MethodCreator
  class Code
    include Jets::Router::Util

    def initialize(action, options, scope)
      @action, @options, @scope = action, options, scope
      @path, @as = options[:path], options[:as]
    end

    def meth_name
      full_as = @scope&.full_as
      path_trunk = @path.split('/').first unless @scope.from == :resources
      join(singularize(full_as), singularize(path_trunk))
    end

    def meth_args
      items = @scope.full_as_meth_args
      return unless items
      "("+items.join(', ')+")"
    end

    def meth_result
      items = @scope.full_as_meth_args
      return unless items
      result = items.map do |x|
        "#{x}/\#{#{x}.to_param}"
      end.join('/')
      "/#{result}"
    end

    def full_meth_name(suffix)
      as =  @as || meth_name
      underscore("#{as}_#{suffix}")
    end

    def path_method
      code =<<~EOL
        def #{full_meth_name(:path)}#{meth_args}
          "#{meth_result}"
        end
      EOL
      # puts code
      code
    end

  private
    def singularize(s)
      return unless s # nil
      s.singularize
    end
  end
end
