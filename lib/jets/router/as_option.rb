class Jets::Router
  class AsOption
    include Util

    def initialize(options)
      @options = options

      @meth, @path, @to, @prefix = @options[:method], @options[:path], @options[:to], @options[:prefix]
      @action = @to.split('#').last

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
      join(@prefix, @path_trunk)
    end

    def new
      join(@action, @prefix, @path_trunk.singularize)
    end

    def show
      join(@prefix, @path_trunk.singularize)
    end

    def edit
      join(@action, @prefix, @path_trunk.singularize)
    end

    # TODO: is this the convention we want? Like it because it is simple
    def stock_get
      join(@action, @prefix, @path_trunk)
    end
  end
end
