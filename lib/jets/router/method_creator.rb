class Jets::Router
  class MethodCreator
    include Util

    def initialize(options, scope)
      @options, @scope = options, scope

      @meth, @path, @to, @as = @options[:method], @options[:path], @options[:to], @options[:as]
      @prefix, @as = @options[:prefix], @options[:as]

      _, @action = get_controller_action(options)
      @path_trunk = @path.split('/').first # posts/new -> posts
    end

    def define_url_helper!
      return unless @meth == :get

      if %w[index new show edit].include?(@action)
        create_method(@action)
      else
        create_method("generic")
      end
    end

    # Examples:
    #
    #   posts_path: path: 'posts'
    #   admin_posts_path: prefix: 'admin', path: 'posts'
    #   new_post_path
    #
    def create_method(action)
      # Code eventually does this:
      #
      #     code = Jets::Router::MethodCreator::Edit.new
      #     def_meth code.path_method
      #
      class_name = "Jets::Router::MethodCreator::#{action.camelize}"
      klass = class_name.constantize # Index, Show, Edit, New
      code = klass.new(@options, @scope)
      puts "define_#{action}_method:".color(:yellow)
      puts code.path_method
      def_meth code.path_method
    end

    def create_root_helper
      # TODO: Support root under nested resources
      as = @options[:as] || "root"
      name = underscore("#{as}_path")

      result = [@prefix, @path].compact.join('/')
      def_meth <<~EOL
        def #{name}
          "/#{result}"
        end
      EOL
    end

    def def_meth(str)
      Jets::RoutesHelper.class_eval(str)
    end
  end
end
