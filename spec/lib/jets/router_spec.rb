describe Jets::Router do
  let(:router) { Jets::Router.new }

  describe "Router" do
    context "nested resources some" do
      it "as path to" do
        router.draw do
          resources :posts, only: :new do
            resources :comments, only: [:edit]
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------------------+------+----------------------------------+-------------------+
|        As         | Verb |               Path               | Controller#action |
+-------------------+------+----------------------------------+-------------------+
| new_post          | GET  | posts/new                        | posts#new         |
| edit_post_comment | GET  | posts/:post_id/comments/:id/edit | comments#edit     |
+-------------------+------+----------------------------------+-------------------+
EOL
        expect(output).to eq(table)
        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Router::Route)
      end
    end

    context "nested resources full" do
      it "as path to" do
        router.draw do
          resources :posts do
            resources :comments
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------------------+--------+----------------------------------+-------------------+
|        As         |  Verb  |               Path               | Controller#action |
+-------------------+--------+----------------------------------+-------------------+
| posts             | GET    | posts                            | posts#index       |
| new_post          | GET    | posts/new                        | posts#new         |
| post              | GET    | posts/:post_id                   | posts#show        |
|                   | POST   | posts                            | posts#create      |
| edit_post         | GET    | posts/:post_id/edit              | posts#edit        |
|                   | PUT    | posts/:post_id                   | posts#update      |
|                   | POST   | posts/:post_id                   | posts#update      |
|                   | PATCH  | posts/:post_id                   | posts#update      |
|                   | DELETE | posts/:post_id                   | posts#delete      |
| post_comments     | GET    | posts/:post_id/comments          | comments#index    |
| new_post_comment  | GET    | posts/:post_id/comments/new      | comments#new      |
| post_comment      | GET    | posts/:post_id/comments/:id      | comments#show     |
|                   | POST   | posts/:post_id/comments          | comments#create   |
| edit_post_comment | GET    | posts/:post_id/comments/:id/edit | comments#edit     |
|                   | PUT    | posts/:post_id/comments/:id      | comments#update   |
|                   | POST   | posts/:post_id/comments/:id      | comments#update   |
|                   | PATCH  | posts/:post_id/comments/:id      | comments#update   |
|                   | DELETE | posts/:post_id/comments/:id      | comments#delete   |
+-------------------+--------+----------------------------------+-------------------+
EOL
        expect(output).to eq(table)
        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Router::Route)
      end
    end

    context "namespace resources full" do
      it "as path to" do
        router.draw do
          namespace :admin do
            resources :posts
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------------+--------+----------------------+--------------------+
|       As        |  Verb  |         Path         | Controller#action  |
+-----------------+--------+----------------------+--------------------+
| admin_posts     | GET    | admin/posts          | admin/posts#index  |
| new_admin_post  | GET    | admin/posts/new      | admin/posts#new    |
| admin_post      | GET    | admin/posts/:id      | admin/posts#show   |
|                 | POST   | admin/posts          | admin/posts#create |
| edit_admin_post | GET    | admin/posts/:id/edit | admin/posts#edit   |
|                 | PUT    | admin/posts/:id      | admin/posts#update |
|                 | POST   | admin/posts/:id      | admin/posts#update |
|                 | PATCH  | admin/posts/:id      | admin/posts#update |
|                 | DELETE | admin/posts/:id      | admin/posts#delete |
+-----------------+--------+----------------------+--------------------+
EOL
        expect(output).to eq(table)
        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Router::Route)
      end
    end

    context "nested namespace nested resources full" do
      it "as path to" do
        router.draw do
          namespace :v1 do
            namespace :admin do
              resources :posts do
                resources :comments
              end
            end
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+----------------------------+--------+-------------------------------------------+--------------------------+
|             As             |  Verb  |                   Path                    |    Controller#action     |
+----------------------------+--------+-------------------------------------------+--------------------------+
| v1_admin_posts             | GET    | v1/admin/posts                            | v1/admin/posts#index     |
| new_v1_admin_post          | GET    | v1/admin/posts/new                        | v1/admin/posts#new       |
| v1_admin_post              | GET    | v1/admin/posts/:post_id                   | v1/admin/posts#show      |
|                            | POST   | v1/admin/posts                            | v1/admin/posts#create    |
| edit_v1_admin_post         | GET    | v1/admin/posts/:post_id/edit              | v1/admin/posts#edit      |
|                            | PUT    | v1/admin/posts/:post_id                   | v1/admin/posts#update    |
|                            | POST   | v1/admin/posts/:post_id                   | v1/admin/posts#update    |
|                            | PATCH  | v1/admin/posts/:post_id                   | v1/admin/posts#update    |
|                            | DELETE | v1/admin/posts/:post_id                   | v1/admin/posts#delete    |
| v1_admin_post_comments     | GET    | v1/admin/posts/:post_id/comments          | v1/admin/comments#index  |
| new_v1_admin_post_comment  | GET    | v1/admin/posts/:post_id/comments/new      | v1/admin/comments#new    |
| v1_admin_post_comment      | GET    | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#show   |
|                            | POST   | v1/admin/posts/:post_id/comments          | v1/admin/comments#create |
| edit_v1_admin_post_comment | GET    | v1/admin/posts/:post_id/comments/:id/edit | v1/admin/comments#edit   |
|                            | PUT    | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#update |
|                            | POST   | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#update |
|                            | PATCH  | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#update |
|                            | DELETE | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#delete |
+----------------------------+--------+-------------------------------------------+--------------------------+
EOL
        expect(output).to eq(table)
        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Router::Route)
      end
    end

    context "nested namespace as string nested resources full" do
      it "as path to" do
        router.draw do
          namespace "v1/admin" do
            resources :posts do
              resources :comments
            end
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+----------------------------+--------+-------------------------------------------+--------------------------+
|             As             |  Verb  |                   Path                    |    Controller#action     |
+----------------------------+--------+-------------------------------------------+--------------------------+
| v1_admin_posts             | GET    | v1/admin/posts                            | v1/admin/posts#index     |
| new_v1_admin_post          | GET    | v1/admin/posts/new                        | v1/admin/posts#new       |
| v1_admin_post              | GET    | v1/admin/posts/:post_id                   | v1/admin/posts#show      |
|                            | POST   | v1/admin/posts                            | v1/admin/posts#create    |
| edit_v1_admin_post         | GET    | v1/admin/posts/:post_id/edit              | v1/admin/posts#edit      |
|                            | PUT    | v1/admin/posts/:post_id                   | v1/admin/posts#update    |
|                            | POST   | v1/admin/posts/:post_id                   | v1/admin/posts#update    |
|                            | PATCH  | v1/admin/posts/:post_id                   | v1/admin/posts#update    |
|                            | DELETE | v1/admin/posts/:post_id                   | v1/admin/posts#delete    |
| v1_admin_post_comments     | GET    | v1/admin/posts/:post_id/comments          | v1/admin/comments#index  |
| new_v1_admin_post_comment  | GET    | v1/admin/posts/:post_id/comments/new      | v1/admin/comments#new    |
| v1_admin_post_comment      | GET    | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#show   |
|                            | POST   | v1/admin/posts/:post_id/comments          | v1/admin/comments#create |
| edit_v1_admin_post_comment | GET    | v1/admin/posts/:post_id/comments/:id/edit | v1/admin/comments#edit   |
|                            | PUT    | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#update |
|                            | POST   | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#update |
|                            | PATCH  | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#update |
|                            | DELETE | v1/admin/posts/:post_id/comments/:id      | v1/admin/comments#delete |
+----------------------------+--------+-------------------------------------------+--------------------------+
EOL
        expect(output).to eq(table)
        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Router::Route)
      end
    end

    context "custom param identifier" do
      it "as path to" do
        router.draw do
          resources :posts do
            resources :comments, param: :my_comment_id
          end
          resources :users, param: :my_user_id
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------------------+--------+---------------------------------------------+-------------------+
|        As         |  Verb  |                    Path                     | Controller#action |
+-------------------+--------+---------------------------------------------+-------------------+
| posts             | GET    | posts                                       | posts#index       |
| new_post          | GET    | posts/new                                   | posts#new         |
| post              | GET    | posts/:post_id                              | posts#show        |
|                   | POST   | posts                                       | posts#create      |
| edit_post         | GET    | posts/:post_id/edit                         | posts#edit        |
|                   | PUT    | posts/:post_id                              | posts#update      |
|                   | POST   | posts/:post_id                              | posts#update      |
|                   | PATCH  | posts/:post_id                              | posts#update      |
|                   | DELETE | posts/:post_id                              | posts#delete      |
| post_comments     | GET    | posts/:post_id/comments                     | comments#index    |
| new_post_comment  | GET    | posts/:post_id/comments/new                 | comments#new      |
| post_comment      | GET    | posts/:post_id/comments/:my_comment_id      | comments#show     |
|                   | POST   | posts/:post_id/comments                     | comments#create   |
| edit_post_comment | GET    | posts/:post_id/comments/:my_comment_id/edit | comments#edit     |
|                   | PUT    | posts/:post_id/comments/:my_comment_id      | comments#update   |
|                   | POST   | posts/:post_id/comments/:my_comment_id      | comments#update   |
|                   | PATCH  | posts/:post_id/comments/:my_comment_id      | comments#update   |
|                   | DELETE | posts/:post_id/comments/:my_comment_id      | comments#delete   |
| users             | GET    | users                                       | users#index       |
| new_user          | GET    | users/new                                   | users#new         |
| user              | GET    | users/:my_user_id                           | users#show        |
|                   | POST   | users                                       | users#create      |
| edit_user         | GET    | users/:my_user_id/edit                      | users#edit        |
|                   | PUT    | users/:my_user_id                           | users#update      |
|                   | POST   | users/:my_user_id                           | users#update      |
|                   | PATCH  | users/:my_user_id                           | users#update      |
|                   | DELETE | users/:my_user_id                           | users#delete      |
+-------------------+--------+---------------------------------------------+-------------------+
EOL
        expect(output).to eq(table)
        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Router::Route)
      end
    end

#######################################################################

    context "main test project" do
      it "draw class method" do
        router = Jets::Router.draw
        expect(router).to be_a(Jets::Router)
        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Router::Route)
      end

      it "builds up routes in memory" do
        # uses fixtures/apps/demo/config/routes.rb
        router.draw do
          resources :articles
          resources :posts
          any "comments/hot", to: "comments#hot"
          get "landing/posts", to: "posts#index"
          get "admin/pages", to: "admin/pages#index"
          get "related_posts/:id", to: "related_posts#show"
          any "others/*proxy", to: "others#catchall"
        end

        expect(router.routes).to be_a(Array)
        expect(router.routes.first).to be_a(Jets::Router::Route)

        # router.routes.each do |route|
        #   puts "route.controller_name #{route.controller_name.inspect}"
        #   puts "route.action_name #{route.action_name.inspect}"
        # end
        # pp Jets::Router.routes
      end

      it "root" do
        router.draw do
          root "posts#index"
        end

        route = router.routes.first
        expect(route).to be_a(Jets::Router::Route)
        expect(route.homepage?).to be true
        expect(route.to).to eq "posts#index"
        expect(route.path).to eq ''
        expect(route.method).to eq "GET"
      end
    end

    context "routes with resources macro" do
      it "expands macro to all the REST routes" do
        router.draw do
          resources :posts
        end
        tos = router.routes.map(&:to).sort.uniq
        expect(tos).to eq(
          ["posts#create", "posts#delete", "posts#edit", "posts#index", "posts#new", "posts#show", "posts#update"].sort
        )
      end

      it "all_paths list all subpaths" do
        router.draw do
          resources :posts
        end
        # pp router.routes # uncomment to debug
        expect(router.all_paths).to eq(
          ["posts", "posts/:id", "posts/:id/edit", "posts/new"]
        )
      end

      it "ordered_routes should sort by precedence" do
        router.draw do
          resources :posts
          any "*catchall", to: "catch#all"
        end
        paths = router.ordered_routes.map(&:path).uniq
        expect(paths).to eq(
          ["posts/new", "posts", "posts/:id/edit", "posts/:id", "*catchall"])
      end
    end

    context "routes with namespaces" do
      # more general scope method
      it "admin namespace" do
        router.draw do
          scope(namespace: :admin) do
            get "posts", to: "posts#index"
          end
        end
        route = router.routes.first
        expect(route.path).to eq "admin/posts"
      end

      it "api/v1 namespace nested" do
        router.draw do
          scope(namespace: :api) do
            scope(namespace: :v1) do
              get "posts", to: "posts#index"
            end
          end
        end
        route = router.routes.first
        expect(route.path).to eq "api/v1/posts"
      end

      it "api/v1 namespace oneline" do
        router.draw do
          scope(module: "api/v1") do
            get "posts", to: "posts#index"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+----+------+-------+--------------------+
| As | Verb | Path  | Controller#action  |
+----+------+-------+--------------------+
|    | GET  | posts | api/v1/posts#index |
+----+------+-------+--------------------+
EOL
        expect(output).to eq(table)
      end

      it "get posts" do
        router.draw do
          get "posts", to: "posts#index"
        end

        output = Jets::Router.help(router.routes).to_s
        puts output
        table =<<EOL
+----+------+-------+--------------------+
| As | Verb | Path  | Controller#action  |
+----+------+-------+--------------------+
|    | GET  | posts | api/v1/posts#index |
+----+------+-------+--------------------+
EOL
        # expect(output).to eq(table)
      end

      # prettier namespace method
      it "api/v2 namespace" do
        router.draw do
          namespace "api/v2" do
            get "posts", to: "posts#index"
          end
        end
        route = router.routes.first
        expect(route.path).to eq "api/v2/posts"
      end


    end
  end
end
