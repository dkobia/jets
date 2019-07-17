class Jets::Router
  class HelperCreator
    include Util

    def initialize(options)
      @options = options

      @meth, @path, @to, @as = @options[:method], @options[:path], @options[:to], @options[:as]
      @prefix, @as = @options[:prefix], @options[:as]

      @controller, @action = @to.split('#')
      @upath, @ucontroller, @uprefix = underscore(@path), underscore(@controller), underscore(@prefix)
      @path_trunk = @path.split('/').first # posts/new -> posts

      @as_option = AsOption.new(options)
    end

    def def_meth(str)
      Jets::RoutesHelper.class_eval(str)
    end

    # Examples:
    #   posts_path: path: 'posts'
    #   admin_posts_path: prefix: 'admin', path: 'posts'
    def define_index_method
      as = @options[:as] || @as_option.index
      name = underscore("#{as}_path")

      result = [@prefix, @path].compact.join('/')

      def_meth <<~EOL
        def #{name}
          "/#{result}"
        end
      EOL
    end

    # Example: new_post_path
    def define_new_method
      as = @options[:as] || @as_option.new
      name = underscore("#{as}_path")

      result = [@prefix, @path_trunk, @action].compact.join('/')

      def_meth <<~EOL
        def #{name}
          "/#{result}"
        end
      EOL
    end

    def define_show_method
      as = @options[:as] || @as_option.show
      name = underscore("#{as}_path")

      result = [@prefix, @path_trunk].compact.join('/')

      # TODO: user_post(user_id, id) ???
      def_meth <<~EOL
        def #{name}(id)
          "/#{result}/" + id.to_param
        end
      EOL
    end

    def define_edit_method
      as = @options[:as] || @as_option.edit
      name = underscore("#{as}_path")

      result = [@prefix, @path_trunk].compact.join('/')

      # TODO: user_post(user_id, id) ???
      def_meth <<~EOL
        def #{name}(id)
          "/#{result}/" + id.to_param + "/#{@action}"
        end
      EOL
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

    #   index - {:to=>"posts#index", :path=>"posts", :method=>:get}
    #   new   - {:to=>"posts#new", :path=>"posts/new", :method=>:get}
    #   show  - {:to=>"posts#show", :path=>"posts/:id", :method=>:get}
    #   edit  - {:to=>"posts#edit", :path=>"posts/:id/edit", :method=>:get}
    #
    #   get "posts", to: "posts#index"
    #   get "posts/new", to: "posts#new" unless api_mode?
    #   get "posts/:id", to: "posts#show"
    #   get "posts/:id/edit", to: "posts#edit" unless api_mode?
    #
    # Interesting, the post, patch, put, and delete lead to the same url helper as the get method...
    #
    #   post "posts", to: "posts#create"
    #   delete "posts/:id", to: "posts#delete"
    #
    #   put "posts/:id", to: "posts#update"
    #   post "posts/:id", to: "posts#update" # for binary uploads
    #   patch "posts/:id", to: "posts#update"
    #
    def define_url_helper!
      return unless @meth == :get

      case @action
      when 'index'
        define_index_method
      when 'new'
        define_new_method
      when 'show'
        define_show_method
      when 'edit'
        define_edit_method
      else
        define_stock_get_method
      end
    end
  end
end
