require 'text-table'

module Jets
  class Router
    include Dsl

    attr_reader :routes
    def initialize
      @routes = []
    end

    def draw(&block)
      instance_eval(&block)
      check_collision!
    end

    # Validate routes that deployable
    def check_collision!
      paths = self.routes.map(&:path)
      collision = Jets::Resource::ApiGateway::RestApi::Routes::Collision.new
      collide = collision.collision?(paths)
      raise collision.exception if collide
    end

    def create_route(options)
      # Currently only using scope to add namespace
      # TODO: Can use it to add additional things like authorization_type
      # Would be good to add authorization_type at the controller level also
      # options[:path] = add_module(options[:path])
      # options[:to] = add_path(options[:to])
      # Note: options[:as] directly pass to HelperCreator

      options[:module] = options[:module] || @scope&.full_module
      options[:prefix] = options[:prefix] || @scope&.full_prefix
      options[:as] = options[:as] || build_as(options) # call after prefix option set

      pp options

      HelperCreator.new(options).define_url_helpers!
      @routes << Route.new(options)
    end

    def build_as(options)
      AsOption.new(options).build
    end

    def api_mode?
      if Jets.config.key?(:api_mode) || Jets.config.key?(:api_generator)
        puts <<~EOL.color(:yellow)
          DEPRECATED: Jets.config.api_generator
          Instead, please update your config/application.rb to use:
            Jets.config.mode = 'api'
          You can also run:
            jets upgrade
        EOL
      end
      api_mode = Jets.config.mode == 'api' || Jets.config.api_mode || Jets.config.api_generator
      api_mode
    end

    # Useful for creating API Gateway Resources
    def all_paths
      results = []
      paths = routes.map(&:path)
      paths.each do |p|
        sub_paths = []
        parts = p.split('/')
        until parts.empty?
          parts.pop
          sub_path = parts.join('/')
          sub_paths << sub_path unless sub_path == ''
        end
        results += sub_paths
      end
      @all_paths = (results + paths).sort.uniq
    end

    # Useful for RouterMatcher
    #
    # Precedence:
    # 1. Routes with no captures get highest precedence: posts/new
    # 2. Then consider the routes with captures: post/:id
    # 3. Last consider the routes with wildcards: *catchall
    #
    # Within these 2 groups we consider the routes with the longest path first
    # since posts/:id and posts/:id/edit can both match.
    def ordered_routes
      length = Proc.new { |r| r.path.length * -1 }
      capture_routes = routes.select { |r| r.path.include?(':') }.sort_by(&length)
      wildcard_routes = routes.select { |r| r.path.include?('*') }.sort_by(&length)
      simple_routes = (routes - capture_routes - wildcard_routes).sort_by(&length)
      simple_routes + capture_routes + wildcard_routes
    end

    def self.has_controller?(name)
      routes.detect { |r| r.controller_name == name }
    end

    # Class methods
    def self.draw
      drawn_router
    end

    @@drawn_router = nil
    def self.drawn_router
      return @@drawn_router if @@drawn_router

      router = Jets.application.routes
      @@drawn_router = router
    end

    def self.clear!
      @@drawn_router = nil
    end

    def self.routes
      drawn_router.routes
    end

    # Returns all paths including subpaths.
    # Example:
    # Input: ["posts/:id/edit"]
    # Output: ["posts", "posts/:id", "posts/:id/edit"]
    def self.all_paths
      drawn_router.all_paths
    end

    def self.routes_help
      return "Your routes table is empty." if routes.empty?

      table = Text::Table.new
      table.head = %w[Verb Path Controller#action]
      routes.each do |route|
        table.rows << [route.method, route.path, route.to]
      end
      table
    end

    def self.all_routes_valid
      invalid_routes.empty?
    end

    def self.invalid_routes
      routes.select { |r| !r.valid? }
    end
  end
end
