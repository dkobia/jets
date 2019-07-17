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
    def resources(*items, **options)
      items.each do |item|
        resources_each(item, options)
      end
    end

    def resources_each(name, options={})
      o = Resources::Options.new(name, options)
      f = Resources::Filter.new(name, options)

      get "#{name}", o.build(:index) if f.pass?(:index)
      get "#{name}/new", o.build(:new) if f.pass?(:new) && !api_mode?
      get "#{name}/:id", o.build(:show) if f.pass?(:show)
      post "#{name}", o.build(:create) if f.pass?(:create)
      get "#{name}/:id/edit", o.build(:edit) if f.pass?(:create) && !api_mode?
      put "#{name}/:id", o.build(:update) if f.pass?(:update)
      post "#{name}/:id", o.build(:update) if f.pass?(:update) # for binary uploads
      patch "#{name}/:id", o.build(:update) if f.pass?(:update)
      delete "#{name}/:id", o.build(:delete) if f.pass?(:delete)
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
