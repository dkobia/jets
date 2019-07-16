class Jets::Router
  module Dsl
    # Methods supported by API Gateway
    %w[any delete get head options patch post put].each do |method_name|
      define_method method_name do |path, options|
        create_route(options.merge(path: path, method: __method__))
      end
    end

    def namespace(ns, &block)
      scope(module: ns, path: ns, as: ns, &block)
    end

    # scope supports three options: module, path and as.
    def scope(options={})
      root_level = @scope.nil?
      @scope = root_level ? Scope.new(options) : @scope.new(options)
      yield
    ensure
      @scope = @scope.parent if @scope
    end

    # resources macro expands to all the routes
    def resources(name)
      get "#{name}", to: "#{name}#index"
      get "#{name}/new", to: "#{name}#new" unless api_mode?
      get "#{name}/:id", to: "#{name}#show"
      post "#{name}", to: "#{name}#create"
      get "#{name}/:id/edit", to: "#{name}#edit" unless api_mode?
      put "#{name}/:id", to: "#{name}#update"
      post "#{name}/:id", to: "#{name}#update" # for binary uploads
      patch "#{name}/:id", to: "#{name}#update"
      delete "#{name}/:id", to: "#{name}#delete"
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
