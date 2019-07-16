class Jets::Router
  class AsOption
    include Util

    def initialize(options)
      @options = options

      @path, @to, @prefix = @options[:path], @options[:to], @options[:prefix]
      @action = @to.split('#').last

      @path_trunk = @path.split('/').first # posts/new -> posts
    end

    def build
      return unless [:index, :new, :show, :edit].include?(@action)
      send(@action)
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

    def stock_get
      join(@action, @prefix, @path_trunk)
    end
  end
end
