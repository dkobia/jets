class Jets::Router::MethodCreator
  class Code
    include Jets::Router::Util

    def initialize(options, scope, action=nil)
      @options, @scope, @action = options, scope, action
      @path, @as = options[:path], options[:as]
    end

    def meth_args
      items = @scope.full_as_meth_args
      return unless items
      items.map! {|x| param_name(x) }
      "("+items.join(', ')+")"
    end

    def action
      @action || self.class.name.split('::').last.downcase
    end

    def full_as
      @scope&.full_as
    end

    def path_trunk
      @path.split('/').first unless @scope.from == :resources
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

    def param_name(name)
      name.to_s.singularize + "_id"
    end

    def walk_scope_parents
      current, i, result = @scope, 0, []
      while current
        yield(current, i, result)
        current = current.parent
        i += 1
      end
      result
    end

  private
    def singularize(s)
      return unless s # nil
      s.singularize
    end
  end
end
