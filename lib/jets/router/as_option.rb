class Jets::Router
  class AsOption
    include Util

    def initialize(options)
      @options = options
      @meth, @path, @to, @as = @options[:method], @options[:path], @options[:to], @options[:as]

      @controller, @action = get_controller_action(options)
      @path_trunk = @path.split('/').first # posts/new -> posts
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
      join(@as, @path_trunk)
    end

    def new
      join(@action, @as, @path_trunk.singularize)
    end

    def show
      join(@as, @path_trunk.singularize)
    end

    def edit
      join(@action, @as, @path_trunk.singularize)
    end

    # TODO: is this the convention we want? Like it because it is simple
    def stock_get
      join(@action, @as, @path_trunk)
    end
  end
end
