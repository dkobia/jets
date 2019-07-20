class Jets::Router::MethodCreator
  class Index < Code
    def meth_name
      # Well this is pretty confusing and tough to follow. TODO: figure out how to improve this.
      #
      # Example 1:
      #
      #     resources :users, only: [] do
      #       resources :posts, only: :index
      #     end
      #
      # Results in:
      #
      #     full_as: user_posts
      #     path_trunk: nil
      #
      # Example 2:
      #
      #     resources :users, only: [] do
      #       get "posts", to: "posts#index"
      #     end
      #
      # Results in:
      #
      #     full_as: users
      #     path_trunk: posts
      #
      # This is because usingn resources contains the parent scope.
      # All the info we need is the scope, scope.full_as already has the desired meth_name.
      #
      # However, when using the simple create_route methods like get, the the parent scope does not contain
      # all the info we need. In this tricky base, the path_trunk is set.
      # We then have to reconstruct the meth_name.
      #
      if path_trunk
        join(singularize(full_as), path_trunk) # construct from path_trunk info also
      else
        join(full_as) # construct entirely from scope info
      end
    end
  end
end
