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

    def show_args
      items = @scope.full_as_meth_args
      "("+items.join(', ')+")"
    end

    def show_result
      items = @scope.full_as_meth_args
      items.map do |x|
        "#{x}/\#{#{x}.to_param}"
      end.join('/')
    end

    def edit
      join(@action, singularize(@full_as), singularize(@path_trunk))
    end

    # TODO: Unsure if is this the convention we want? What about when method has arguments?
    def stock_get
      join(@action, @full_as, @path_trunk)
    end

    # Support root under nested resources
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
