class Jets::Router
  module Dsl
    # Methods supported by API Gateway
    %w[any delete get head options patch post put].each do |method_name|
      define_method method_name do |path, options|
        create_route(options.merge(path: path, method: __method__))
      end
    end

    def namespace(ns, &block)
      scope(module: ns, prefix: ns, as: ns, &block)
    end

    # scope supports three options: module, prefix and as.
    # Jets vs Rails:
    #   module - module
    #   prefix - path
    #   as - as
    def scope(options={})
      root_level = @scope.nil?
      @scope = root_level ? Scope.new(options) : @scope.new(options)
      yield
    ensure
      @scope = @scope.parent if @scope
    end

    # resources macro expands to all the routes
    def resources(name, options={})
      options = ResourcesOptions.new(name, options)

      get "#{name}", options.build(:index)
      get "#{name}/new", options.build(:new) unless api_mode?
      get "#{name}/:id", options.build(:show)
      post "#{name}", options.build(:create)
      get "#{name}/:id/edit", options.build(:edit) unless api_mode?
      put "#{name}/:id", options.build(:update)
      post "#{name}/:id", options.build(:update) # for binary uploads
      patch "#{name}/:id", options.build(:update)
      delete "#{name}/:id", options.build(:delete)
    end

    # root "posts#index"
    def root(to, options={})
      default = {path: '', to: to, method: :get, root: true}
      options = default.merge(options)
      # TODO: define root_url helper
      @routes << Route.new(options)
    end
  end
end
