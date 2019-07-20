class Jets::Router::MethodCreator
  class Code
    include Jets::Router::Util

    def initialize(options, scope, action=nil)
      @options, @scope, @action = options, scope, action
      @path, @as = options[:path], options[:as]
    end

    def meth_args
      params = full_path.split('/').select { |x| x.include?(':') }
      items = params.map { |x| x.sub(':','') }

      items.empty? ? nil : "("+items.join(', ')+")"
    end

    def meth_result
      results = full_path.split('/').map do |x|
        if x.include?(':')
          variable = x.sub(':','')
          "\#{#{variable}.to_param}"
        else
          x
        end
      end

      '/' + results.join('/') unless results.empty?
    end

    def full_path
      prefix = @scope.full_prefix
      path = [prefix, @options[:path]].compact.join('/')
    end

    def action
      @action || self.class.name.split('::').last.downcase
    end

    def full_as
      @scope&.full_as
    end

    # The path_method is mainly use to generate method names.
    # But it's also sometimes use for the result, like in index.rb.
    # TODO: Clean this up and make more understanable.
    def path_trunk
      @path.to_s.split('/').first unless @scope.from == :resources || @scope.from == :resource
    end

    def full_meth_name(suffix)
      as =  @as || meth_name
      underscore("#{as}_#{suffix}")
    end

    def path_method
      <<~EOL
        def #{full_meth_name(:path)}#{meth_args}
          "#{meth_result}"
        end
      EOL
    end

    def param_name(name)
      # split('/').last for case:
      #
      #   resources :posts, prefix: "articles", only: :index do
      #     resources :comments, only: :new
      #   end
      #
      # Since the prefix at the scope level is added to the posts item, which results in:
      #
      #   param_name("articles/posts")
      #
      # We drop the articles prefix portion. The resources items can only be words with no /.
      #
      name.to_s.split('/').last.singularize + "_id"
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
