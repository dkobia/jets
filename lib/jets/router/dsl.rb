class Jets::Router
  module Dsl
    # Methods supported by API Gateway
    %w[any delete get head options patch post put].each do |method_name|
      define_method method_name do |path, options|
        create_route(options.merge(path: path, method: __method__))
      end
    end

    def namespace(ns, &block)
      scope(module: ns, prefix: ns, as: ns, from: :namespace, &block)
    end

    # scope supports three options: module, prefix and as.
    # Jets vs Rails:
    #   module - module
    #   prefix - path
    #   as - as
    def scope(args)
      # normalizes `scope(:admin)` as `scope(prefix: :admin)`
      options = case args
      when Hash
        args
      when String, Symbol
        { prefix: args }
      end

      root_level = @scope.nil?
      @scope = root_level ? Scope.new(options) : @scope.new(options)
      yield
    ensure
      @scope = @scope.parent if @scope
    end

    # resources macro expands to all the routes
    def resources(*items, **options)
      items.each do |item|
        scope_options = scope_options!(item, options)
        scope(scope_options) do
          resources_each(item, options, block_given?)
          yield if block_given?
        end
      end
    end

    def scope_options!(item, options)
      {
        as: options.delete(:as) || item,
        prefix: options.delete(:prefix) || item,
        # module: options.delete(:module) || item, # NOTE: resources does not automatically set module, but namespace does
        from: :resources, # flag we can disregard @path_trunk in MethodCreator logic.
      }
    end

    def resources_each(name, options={}, has_block)
      o = Resources::Options.new(name, options)
      f = Resources::Filter.new(name, options)
      param = default_param(has_block, name, options)

      get name, o.build(:index) if f.yes?(:index)
      get "#{name}/new", o.build(:new) if f.yes?(:new) && !api_mode?
      get "#{name}/:#{param}", o.build(:show) if f.yes?(:show)
      post name, o.build(:create) if f.yes?(:create)
      get "#{name}/:#{param}/edit", o.build(:edit) if f.yes?(:edit) && !api_mode?
      put "#{name}/:#{param}", o.build(:update) if f.yes?(:update)
      post "#{name}/:#{param}", o.build(:update) if f.yes?(:update) # for binary uploads
      patch "#{name}/:#{param}", o.build(:update) if f.yes?(:update)
      delete "#{name}/:#{param}", o.build(:delete) if f.yes?(:delete)
    end

    def resource(*items, **options)
      items.each do |item|
        scope_options = scope_options!(item, options)
        scope(scope_options) do
          resource_each(item, options, block_given?)
          yield if block_given?
        end
      end
    end

    def resource_each(name, options={}, has_block)
      o = Resources::Options.new(name, options.merge(singular_resource: true))
      f = Resources::Filter.new(name, options)

      get "#{name}/new", o.build(:new) if f.yes?(:new) && !api_mode?
      get name, o.build(:show) if f.yes?(:show)
      post name, o.build(:create) if f.yes?(:create)
      get "#{name}/edit", o.build(:edit) if f.yes?(:edit) && !api_mode?
      put name, o.build(:update) if f.yes?(:update)
      post name, o.build(:update) if f.yes?(:update) # for binary uploads
      patch name, o.build(:update) if f.yes?(:update)
      delete name, o.build(:delete) if f.yes?(:delete)
    end

    # If a block has pass then we assume the resources will be nested and then prefix
    # the param name with the resource. IE: post_id instead of id
    # This avoids an API Gateway parent sibling variable collision.
    def default_param(has_block, name, options)
      default_param = has_block ? "#{name.to_s.singularize}_id".to_sym : :id
      options[:param] || default_param
    end

    # root "posts#index"
    def root(to, options={})
      default = {path: '', to: to, method: :get, root: true}
      options = default.merge(options)
      MethodCreator.new(options, @scope).create_root_helper
      @routes << Route.new(options, @scope)
    end
  end
end
