class Jets::Router
  class HelperCreator
    def initialize(options)
      @options = options
    end

    def define_url_helpers!
      puts "define_url_helper options #{@options.inspect}"

      # index - {:to=>"posts#index", :path=>"posts", :method=>:get}
      # new   - {:to=>"posts#new", :path=>"posts/new", :method=>:get}
      # show  - {:to=>"posts#show", :path=>"posts/:id", :method=>:get}
      # edit  - {:to=>"posts#edit", :path=>"posts/:id/edit", :method=>:get}
      meth = @options[:method]
      path = @options[:path]
      to = @options[:to]
      controller_name = to.split('')

      # Notes: prefix is related to path in Rails

      # get "posts", to: "posts#index"
      # get "posts/new", to: "posts#new" unless api_mode?
      # get "posts/:id", to: "posts#show"
      # get "posts/:id/edit", to: "posts#edit" unless api_mode?
      if meth == :get
        if !path.include?('/') # index action
          # Example: posts_path
          Jets::RoutesHelper.class_eval <<~EOL
            def #{path}_path
              "/#{path}"
            end
          EOL
        elsif !path.include?(':') # new action
          # prefix = path.to_s.gsub('/','_').singularize # If want to behave the same way as Rails
          controller, action = path.split('/')[-2..-1] # TODO: account for namespace or extra prefixes in path
          prefix = "#{action}_#{controller.singularize}"
          # Example: new_post_path
          Jets::RoutesHelper.class_eval <<~EOL
            def #{prefix}_path
              "/#{controller}/#{action}"
            end
          EOL
        elsif path.include?(':') && path =~ %r{/:\w+/} # edit action
          # TODO: account for namespace or extra prefixes in path
          controller = path.split('/').first
          action = path.split('/').last
          prefix = "#{action}_#{controller.singularize}"

          Jets::RoutesHelper.class_eval <<~EOL
            def #{prefix}_path(id)
              # TODO: figure out how to handle different types of objects, not just ids
              "/#{controller}/" + id.to_s + "/#{action}"
            end
          EOL
        elsif path.include?(':') && path !~ %r{/:\w+/} # show action
          # TODO: account for namespace or extra prefixes in path
          controller = path.split('/').first
          prefix = controller.singularize

          Jets::RoutesHelper.class_eval <<~EOL
            def #{prefix}_path(id)
              "/#{controller}/" + id.to_s
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
