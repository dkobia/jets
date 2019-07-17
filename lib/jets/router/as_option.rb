class Jets::Router
  class AsOption
    include Util

    def initialize(options, scope)
      @options, @scope = options, scope

      @meth, @path, @to, @as = @options[:method], @options[:path], @options[:to], @options[:as]

      @controller, @action = get_controller_action(options)

      # posts/new -> posts
      # @path_trunk = @path.split('/').first if @scope.options[:namespace]
      @path_trunk = nil

      # puts "as_option.rb @scope".color(:yellow)
      # pp scope
      @full_as = @scope&.full(:as)
      @full_as.singularize if @scope.resources?
      # puts "@full_as #{@full_as}".color(:yellow)
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
      join(@action, @full_as.singularize, @path_trunk&.singularize)
    end

    def show
      join(@full_as.singularize, @path_trunk&.singularize)
    end

    def edit
      join(@action, @full_as.singularize, @path_trunk&.singularize)
    end

    # TODO: is this the convention we want? Like it because it is simple
    def stock_get
      join(@action, @full_as, @path_trunk)
    end
  end
end
