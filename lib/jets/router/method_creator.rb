class Jets::Router
  class MethodCreator
    include Util

    def initialize(options, scope)
      @options, @scope = options, scope

      @meth, @path, @to, @as = @options[:method], @options[:path], @options[:to], @options[:as]
      @prefix, @as = @options[:prefix], @options[:as]

      _, @action = get_controller_action(options)
      @path_trunk = @path.split('/').first # posts/new -> posts

      @as_option = AsOption.new(options, scope)
    end

    def define_url_helper!
      return unless @meth == :get

      if %w[index new show edit].include?(@action)
        create_method(@action)
      else
        define_stock_get_method
      end
    end

    # Examples:
    #
    #   posts_path: path: 'posts'
    #   admin_posts_path: prefix: 'admin', path: 'posts'
    #   new_post_path
    #
    def create_method(action)
      class_name = "Jets::Router::MethodCreator::#{action.camelize}"
      klass = class_name.constantize # Index, Show, Edit, New
      code = klass.new(@options, @scope)
      puts "define_#{action}_method:".color(:yellow)
      puts code.path_method
      def_meth code.path_method
    end

    def def_meth(str)
      Jets::RoutesHelper.class_eval(str)
    end

    def define_stock_get_method
      as = @options[:as] || @as_option.stock_get
      name = underscore("#{as}_path")

      result = [@prefix, @path].compact.join('/')

      # TODO: user_post(user_id, id) ???
      def_meth <<~EOL
        def #{name}(id)
          "/#{result}/" + id.to_param + "/#{@action}"
        end
      EOL
    end

    def define_root_helper
      as = @options[:as] || @as_option.root
      name = underscore("#{as}_path")

      result = [@prefix, @path].compact.join('/')

      def_meth <<~EOL
        def #{name}
          "/#{result}"
        end
      EOL
    end
  end
end
