class Jets::Router
  class AsOption
    def initialize(options)
      @options = options

      @path, @to = @options[:path], @options[:to]
      @action = @to.split('#').last

      @path_trunk = @path.split('/').first # posts/new -> posts
    end

    def build
      return unless [:index, :new, :show, :edit].include?(@action)
      send(@action)
    end

    def index
      @path_trunk
    end

    def new
      [@action, @path_trunk.singularize].compact.join('_')
    end

    def show
      @path_trunk.singularize
    end

    def edit
      [@action, @path_trunk.singularize].compact.join('_')
    end
  end
end
