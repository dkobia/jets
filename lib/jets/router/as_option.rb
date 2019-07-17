class Jets::Router
  class AsOption
    include Util

    def initialize(options, scope)
      @options, @scope = options, scope

      @meth, @path, @to, @as = @options[:method], @options[:path], @options[:to], @options[:as]
      @controller, @action = get_controller_action(options)

      # @path_trunk: posts/new -> posts
      # unless @scope.from == :resources because resources creates an extra layer
      @path_trunk = @path.split('/').first unless @scope.from == :resources
      @full_as = @scope&.full_as
    end

    def build
      return send(:root) if @options[:root]

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
      join(@action, singularize(@full_as), singularize(@path_trunk))
    end

    def show
      join(singularize(@full_as), singularize(@path_trunk))
    end

    def edit
      join(@action, singularize(@full_as), singularize(@path_trunk))
    end

    # TODO: is this the convention we want? Like it because it is simple
    def stock_get
      join(@action, @full_as, @path_trunk)
    end

    def root
      "root"
    end

  private
    def singularize(s)
      return unless s # nil
      s.singularize
    end
  end
end
