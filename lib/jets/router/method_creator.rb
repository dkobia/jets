class Jets::Router
  class MethodCreator
    include Util

    def initialize(options, scope)
      @options, @scope = options, scope
    end

    def define_url_helper!
      return unless @options[:method] == :get

      _, action = get_controller_action(@options)
      if %w[index new show edit].include?(action)
        create_method(action)
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
      # puts "define_#{action}_method:".color(:yellow)
      # puts code.path_method.color(:blue)
      def_meth code.path_method
    end

    def create_root_helper
      code = Jets::Router::MethodCreator::Root.new(@options, @scope)
      def_meth code.path_method
    end

    def def_meth(str)
      Jets::RoutesHelper.class_eval(str)
    end
  end
end
