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
      # This is because using resources contains all the info we need in parent scopes.
      # The scope.full_as already has the desired meth_name.
      #
      # However, when using the simple create_route methods like get, the parent scope does not contain
      # all the info we need. In this tricky case, the path_trunk is set.
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
