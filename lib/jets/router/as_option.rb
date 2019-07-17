class Jets::Router
  class AsOption
    include Util

    def initialize(options, scope)
      @options, @scope = options, scope

      @meth, @path, @to, @as = @options[:method], @options[:path], @options[:to], @options[:as]

      @controller, @action = get_controller_action(options)

      # @scope.resources? means the as option comes from within a resource declaration
      #
      #     resources :posts, as: 'images'
      #
      # Use this flag in the AsOption builder to disregard the @path_trunk
      #
      # Else we get the @path_trunk from the @path
      #
      #     posts/new -> posts
      @path_trunk = @path.split('/').first unless @scope.resources?
      @full_as = @scope&.full(:as)
    end

    def build
      return unless @meth == :get

      if %w[index new show edit].include?(@action)
        send(@action)
      else
        stock_get
      end
    end

    def index
      join(@full_as, @path_trunk)
    end

    def new
      join(@action, @full_as, @path_trunk&.singularize)
    end

    def show
      join(@full_as, @path_trunk&.singularize)
    end

    def edit
      join(@action, @full_as, @path_trunk&.singularize)
    end

    # TODO: is this the convention we want? Like it because it is simple
    def stock_get
      join(@action, @full_as, @path_trunk)
    end
  end
end
