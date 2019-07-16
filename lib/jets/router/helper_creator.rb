class Jets::Router
  class HelperCreator
    def initialize(options, helper_module=nil)
      @options = options
      @helper_module = helper_module || Jets::RoutesHelper
    end

    def def_meth(str)
      @helper_module.class_eval(str)
    end

    def sanitize(str)
      str.gsub('-','_').gsub('/','_')
    end

    def define_url_helpers!
      # puts "define_url_helper options #{@options.inspect}"

      # index - {:to=>"posts#index", :path=>"posts", :method=>:get}
      # new   - {:to=>"posts#new", :path=>"posts/new", :method=>:get}
      # show  - {:to=>"posts#show", :path=>"posts/:id", :method=>:get}
      # edit  - {:to=>"posts#edit", :path=>"posts/:id/edit", :method=>:get}
      meth = @options[:method]
      path = @options[:path]
      to = @options[:to]

      controller, action = to.split('#')
      spath = sanitize(path)
      scontroller = sanitize(controller)

      # Notes: spath is related to path in Rails

      # get "posts", to: "posts#index"
      # get "posts/new", to: "posts#new" unless api_mode?
      # get "posts/:id", to: "posts#show"
      # get "posts/:id/edit", to: "posts#edit" unless api_mode?
      if meth == :get
        case action
        when 'index'
          as = @options[:as] || "#{spath}_path"
          # Example: posts_path
          def_meth <<~EOL
            def #{as}
              "/#{path}"
            end
          EOL
        when 'new'
          prefix = "#{action}_#{scontroller.singularize}"
          # Example: new_post_path
          def_meth <<~EOL
            def #{prefix}_path
              "/#{controller}/#{action}"
            end
          EOL
        when 'edit'
          # TODO: account for namespace or extra prefixes in path
          prefix = "#{action}_#{scontroller.singularize}"

          def_meth <<~EOL
            def #{prefix}_path(id)
              # TODO: figure out how to handle different types of objects, not just ids
              "/#{controller}/" + id.to_param + "/#{action}"
            end
          EOL
        when 'show'
          # TODO: account for namespace or extra prefixes in path
          prefix = scontroller.singularize

          def_meth <<~EOL
            def #{prefix}_path(id)
              "/#{controller}/" + id.to_param
            end
          EOL
        end
      end

      # Interesting, the post, patch, put, and delete lead to the same url helper as the get method...

      # post "posts", to: "posts#create"
      # delete "posts/:id", to: "posts#delete"

      # put "posts/:id", to: "posts#update"
      # post "posts/:id", to: "posts#update" # for binary uploads
      # patch "posts/:id", to: "posts#update"

    end
  end
end
