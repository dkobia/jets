class RouterTestApp
  include Jets::RoutesHelper
end

describe Jets::Router do
  let(:router) { Jets::Router.new }
  let(:app)    { RouterTestApp.new }

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
      it "testnow posts comments" do
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

        expect(app.posts_path).to eq("/posts")
        expect(app.new_post_path).to eq("/posts/new")
        expect(app.post_path(1)).to eq("/posts/1")
        expect(app.edit_post_comment_path(1, 2)).to eq("/posts/1/comments/2/edit")

        expect(app.post_comments_path(1)).to eq("/posts/1/comments")
        expect(app.new_post_comment_path(1)).to eq("/posts/1/comments/new")
        expect(app.post_comment_path(1, 2)).to eq("/posts/1/comments/2")
        expect(app.edit_post_comment_path(1, 2)).to eq("/posts/1/comments/2/edit")
      end
    end

    # Its possible to capture the scope from the DSL. Still weird to create the method though.
    # Leaving this around as an example in case leads to a better way of doing it.
    context "example of captured scope" do
      it "namespace admin posts" do
        captured_scope = nil
        router.draw do
          namespace :admin do
            resources :posts, only: [] do
              captured_scope = @scope
            end
          end
        end

        options = {:to=>"posts#index", :path=>"posts", :method=>:get}
        creator = Jets::Router::MethodCreator::Index.new(options, captured_scope)
        expect(creator.path_method).to eq(<<~EOL)
          def admin_posts_path
            "/admin/posts"
          end
        EOL
      end

      it "resources users posts" do
        captured_scope = nil
        router.draw do
          resources :users, only: [] do
            resources :posts, only: [] do
              captured_scope = @scope
            end
          end
        end

        options = {:to=>"posts#index", :path=>"posts", :method=>:get}
        creator = Jets::Router::MethodCreator::Index.new(options, captured_scope)
        expect(creator.path_method).to eq(<<~'EOL')
          def user_posts_path(user_id)
            "/users/#{user_id.to_param}/posts"
          end
        EOL
      end
    end

    context "namespace resources full" do
      it "testnow admin posts" do
        captured_scope = nil
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

        expect(app.admin_posts_path).to eq("/admin/posts")
        expect(app.new_admin_post_path).to eq("/admin/posts/new")
        expect(app.admin_post_path(1)).to eq("/admin/posts/1")
        expect(app.edit_admin_post_path(1)).to eq("/admin/posts/1/edit")
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
      end

      it "standalone routes" do
        router.draw do
          any "comments/hot", to: "comments#hot"
          get "landing/posts", to: "posts#index"
          get "admin/pages", to: "admin/pages#index"
          get "related_posts/:id", to: "related_posts#show"
          any "others/*proxy", to: "others#catchall"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------------+------+-------------------+--------------------+
|      As      | Verb |       Path        | Controller#action  |
+--------------+------+-------------------+--------------------+
|              | ANY  | comments/hot      | comments#hot       |
| landing      | GET  | landing/posts     | posts#index        |
| admin        | GET  | admin/pages       | admin/pages#index  |
| related_post | GET  | related_posts/:id | related_posts#show |
|              | ANY  | others/*proxy     | others#catchall    |
+--------------+------+-------------------+--------------------+
EOL
        expect(output).to eq(table)
      end

      it "builds up routes in memory" do
        router.draw do
          resources :articles
          resources :posts
          any "comments/hot", to: "comments#hot"
          get "landing/posts", to: "posts#index"
          get "admin/pages", to: "admin/pages#index"
          get "related_posts/:id", to: "related_posts#show"
          any "others/*proxy", to: "others#catchall"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------------+--------+-------------------+--------------------+
|      As      |  Verb  |       Path        | Controller#action  |
+--------------+--------+-------------------+--------------------+
| articles     | GET    | articles          | articles#index     |
| new_article  | GET    | articles/new      | articles#new       |
| article      | GET    | articles/:id      | articles#show      |
|              | POST   | articles          | articles#create    |
| edit_article | GET    | articles/:id/edit | articles#edit      |
|              | PUT    | articles/:id      | articles#update    |
|              | POST   | articles/:id      | articles#update    |
|              | PATCH  | articles/:id      | articles#update    |
|              | DELETE | articles/:id      | articles#delete    |
| posts        | GET    | posts             | posts#index        |
| new_post     | GET    | posts/new         | posts#new          |
| post         | GET    | posts/:id         | posts#show         |
|              | POST   | posts             | posts#create       |
| edit_post    | GET    | posts/:id/edit    | posts#edit         |
|              | PUT    | posts/:id         | posts#update       |
|              | POST   | posts/:id         | posts#update       |
|              | PATCH  | posts/:id         | posts#update       |
|              | DELETE | posts/:id         | posts#delete       |
|              | ANY    | comments/hot      | comments#hot       |
| landing      | GET    | landing/posts     | posts#index        |
| admin        | GET    | admin/pages       | admin/pages#index  |
| related_post | GET    | related_posts/:id | related_posts#show |
|              | ANY    | others/*proxy     | others#catchall    |
+--------------+--------+-------------------+--------------------+
EOL
        expect(output).to eq(table)
      end

      it "root" do
        router.draw do
          root "posts#index"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+------+------+------+-------------------+
|  As  | Verb | Path | Controller#action |
+------+------+------+-------------------+
| root | GET  |      | posts#index       |
+------+------+------+-------------------+
EOL
        expect(output).to eq(table)

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

    context "scope with module" do
      # more general scope method
      it "admin module" do
        router.draw do
          scope(module: :admin) do
            get "posts", to: "posts#index"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+-------+-------------------+
|  As   | Verb | Path  | Controller#action |
+-------+------+-------+-------------------+
| posts | GET  | posts | admin/posts#index |
+-------+------+-------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "api/v1 module nested" do
        router.draw do
          scope(module: :api) do
            scope(module: :v1) do
              get "posts", to: "posts#index"
            end
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+-------+--------------------+
|  As   | Verb | Path  | Controller#action  |
+-------+------+-------+--------------------+
| posts | GET  | posts | api/v1/posts#index |
+-------+------+-------+--------------------+
EOL
        expect(output).to eq(table)
      end

      it "api/v1 module oneline" do
        router.draw do
          scope(module: "api/v1") do
            get "posts", to: "posts#index"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+-------+--------------------+
|  As   | Verb | Path  | Controller#action  |
+-------+------+-------+--------------------+
| posts | GET  | posts | api/v1/posts#index |
+-------+------+-------+--------------------+
EOL
        expect(output).to eq(table)
      end

      it "get posts 1" do
        router.draw do
          resources :posts
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------+--------+----------------+-------------------+
|    As     |  Verb  |      Path      | Controller#action |
+-----------+--------+----------------+-------------------+
| posts     | GET    | posts          | posts#index       |
| new_post  | GET    | posts/new      | posts#new         |
| post      | GET    | posts/:id      | posts#show        |
|           | POST   | posts          | posts#create      |
| edit_post | GET    | posts/:id/edit | posts#edit        |
|           | PUT    | posts/:id      | posts#update      |
|           | POST   | posts/:id      | posts#update      |
|           | PATCH  | posts/:id      | posts#update      |
|           | DELETE | posts/:id      | posts#delete      |
+-----------+--------+----------------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "get posts 2" do
        router.draw do
          get "posts", to: "posts#index"
          get "posts/new", to: "posts#new"
          get "posts/:id", to: "posts#show"
          post "posts", to: "posts#create"
          get "posts/:id/edit", to: "posts#edit"
          put "posts/:id", to: "posts#update"
          post "posts/:id", to: "posts#update"
          patch "posts/:id", to: "posts#update"
          delete "posts/:id", to: "posts#delete"
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------+--------+----------------+-------------------+
|    As     |  Verb  |      Path      | Controller#action |
+-----------+--------+----------------+-------------------+
| posts     | GET    | posts          | posts#index       |
| new_post  | GET    | posts/new      | posts#new         |
| post      | GET    | posts/:id      | posts#show        |
|           | POST   | posts          | posts#create      |
| edit_post | GET    | posts/:id/edit | posts#edit        |
|           | PUT    | posts/:id      | posts#update      |
|           | POST   | posts/:id      | posts#update      |
|           | PATCH  | posts/:id      | posts#update      |
|           | DELETE | posts/:id      | posts#delete      |
+-----------+--------+----------------+-------------------+
EOL
        expect(output).to eq(table)
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

    # context "main test project" do
    #   it "draw class method" do
    #     router = Jets::Router.draw
    #     expect(router).to be_a(Jets::Router)
    #     expect(router.routes).to be_a(Array)
    #     expect(router.routes.first).to be_a(Jets::Router::Route)
    #   end
    # end

    context "scope with prefix" do
      it "single admin prefix" do
        router.draw do
          scope(prefix: :admin) do
            get "posts", to: "posts#index"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+-------------+-------------------+
|  As   | Verb |    Path     | Controller#action |
+-------+------+-------------+-------------------+
| posts | GET  | admin/posts | posts#index       |
+-------+------+-------------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "nested admin prefix on multiple lines" do
        router.draw do
          scope(prefix: :v1) do
            scope(prefix: :admin) do
              get "posts", to: "posts#index"
            end
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+----------------+-------------------+
|  As   | Verb |      Path      | Controller#action |
+-------+------+----------------+-------------------+
| posts | GET  | v1/admin/posts | posts#index       |
+-------+------+----------------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "nested admin prefix on oneline" do
        router.draw do
          scope(prefix: :v1) do
            scope(prefix: :admin) do
              get "posts", to: "posts#index"
            end
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+----------------+-------------------+
|  As   | Verb |      Path      | Controller#action |
+-------+------+----------------+-------------------+
| posts | GET  | v1/admin/posts | posts#index       |
+-------+------+----------------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "nested admin prefix as string" do
        router.draw do
          scope "v1/admin" do
            get "posts", to: "posts#index"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+----------------+-------------------+
|  As   | Verb |      Path      | Controller#action |
+-------+------+----------------+-------------------+
| posts | GET  | v1/admin/posts | posts#index       |
+-------+------+----------------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "nested admin prefix as symbol" do
        router.draw do
          scope :admin do
            get "posts", to: "posts#index"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-------+------+-------------+-------------------+
|  As   | Verb |    Path     | Controller#action |
+-------+------+-------------+-------------------+
| posts | GET  | admin/posts | posts#index       |
+-------+------+-------------+-------------------+
EOL
        expect(output).to eq(table)
      end
    end

    context "scope with as" do
      it "single admin as with individual routes" do
        router.draw do
          scope(as: :admin) do
            get "posts", to: "posts#index"
            get "posts/new", to: "posts#new"
            get "posts/:id", to: "posts#show"
            post "posts", to: "posts#create"
            get "posts/:id/edit", to: "posts#edit"
            put "posts/:id", to: "posts#update"
            post "posts/:id", to: "posts#update"
            patch "posts/:id", to: "posts#update"
            delete "posts/:id", to: "posts#delete"
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------------+--------+----------------+-------------------+
|       As        |  Verb  |      Path      | Controller#action |
+-----------------+--------+----------------+-------------------+
| admin_posts     | GET    | posts          | posts#index       |
| new_admin_post  | GET    | posts/new      | posts#new         |
| admin_post      | GET    | posts/:id      | posts#show        |
|                 | POST   | posts          | posts#create      |
| edit_admin_post | GET    | posts/:id/edit | posts#edit        |
|                 | PUT    | posts/:id      | posts#update      |
|                 | POST   | posts/:id      | posts#update      |
|                 | PATCH  | posts/:id      | posts#update      |
|                 | DELETE | posts/:id      | posts#delete      |
+-----------------+--------+----------------+-------------------+
EOL
        expect(output).to eq(table)
      end

      it "single admin as with resources" do
        router.draw do
          scope(as: :admin) do
            resources :posts
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+-----------------+--------+----------------+-------------------+
|       As        |  Verb  |      Path      | Controller#action |
+-----------------+--------+----------------+-------------------+
| admin_posts     | GET    | posts          | posts#index       |
| new_admin_post  | GET    | posts/new      | posts#new         |
| admin_post      | GET    | posts/:id      | posts#show        |
|                 | POST   | posts          | posts#create      |
| edit_admin_post | GET    | posts/:id/edit | posts#edit        |
|                 | PUT    | posts/:id      | posts#update      |
|                 | POST   | posts/:id      | posts#update      |
|                 | PATCH  | posts/:id      | posts#update      |
|                 | DELETE | posts/:id      | posts#delete      |
+-----------------+--------+----------------+-------------------+
EOL
        expect(output).to eq(table)
      end
    end

    # useful for debugging code
    context "simple routes" do
      it "post_comment" do
        router.draw do
          resources :posts, only: [] do
            resources :comments, only: :show
          end
        end

        output = Jets::Router.help(router.routes).to_s
        table =<<EOL
+--------------+------+-----------------------------+-------------------+
|      As      | Verb |            Path             | Controller#action |
+--------------+------+-----------------------------+-------------------+
| post_comment | GET  | posts/:post_id/comments/:id | comments#show     |
+--------------+------+-----------------------------+-------------------+
EOL
        expect(output).to eq(table)

        path = app.post_comment_path(:a, :b)
        expect(path).to eq("/posts/a/comments/b")
      end

      it "post_comment2" do
        router.draw do
          resources :posts
        end

        output = Jets::Router.help(router.routes).to_s
        puts output
        table =<<EOL
EOL
        # expect(output).to eq(table)

        expect(app.post_path(:a)).to eq("/posts/a")
      end

      it "post_comment3" do
        router.draw do
          resources :posts do
            resources :comments do
            end
          end
        end

        output = Jets::Router.help(router.routes).to_s
        puts output
        table =<<EOL
EOL
        # expect(output).to eq(table)

        # expect(app.post_comment_path(:a, :b)).to eq("/posts/a/comments/b")
      end
    end
  end
end
