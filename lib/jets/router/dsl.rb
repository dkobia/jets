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
        scope_options = scope_options!(item, options)
        # puts "dsl.rb item #{item}".color(:yellow)
        # puts "scope_options #{scope_options}"
        scope(scope_options) do
          resources_each(item, options)
          yield if block_given?
        end
      end
    end

    def scope_options!(item, options)
      {
        as: options[:as] || item,
        prefix: options[:prefix] || item,
        # module: options[:module] || item,
        resources: true, # flag we can disregard @path_trunk in AsOption class.
      }
    end

    def resources_each(name, options={})
      o = Resources::Options.new(name, options)
      f = Resources::Filter.new(name, options)

      param = options[:param] || :id

      get "#{name}", o.build(:index) if f.yes?(:index)
      get "#{name}/new", o.build(:new) if f.yes?(:new) && !api_mode?
      get "#{name}/:#{param}", o.build(:show) if f.yes?(:show)
      post "#{name}", o.build(:create) if f.yes?(:create)
      get "#{name}/:#{param}/edit", o.build(:edit) if f.yes?(:edit) && !api_mode?
      put "#{name}/:#{param}", o.build(:update) if f.yes?(:update)
      post "#{name}/:#{param}", o.build(:update) if f.yes?(:update) # for binary uploads
      patch "#{name}/:#{param}", o.build(:update) if f.yes?(:update)
      delete "#{name}/:#{param}", o.build(:delete) if f.yes?(:delete)
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
