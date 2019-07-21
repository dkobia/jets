---
title: Routing Guide
---

## 1. Introduction

Jets routing translates your `routes.rb` file into API Gateway resources and connects them to your Lambda functions. It also generates helper methods for URL paths for your convenience.

## 2. Resources

Jets routing leverages a REST architecture design by default.  A key component of a REST are resources. With HTTP, we can take actions like GET, POST, PUT, PATCH, DELETE on resources. Jets uses HTTP verbs and RESTful resources to achieve the common CRUD pattern: Create, Read, Update, and Delete.

With the `resources` method, Jets creates CRUD-related routes. Example:

config/routes.rb:

```ruby
resources :posts
````

Generates:

```
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
```

### 2.1 only and except options

You can use the `only` and `except` options with the `resources` method to select which routes you want.

Here's an example with `only`:

```ruby
resources :posts, only: %w[index show]
```

Results in:

```
+-------+------+-----------+-------------------+
|  As   | Verb |   Path    | Controller#action |
+-------+------+-----------+-------------------+
| posts | GET  | posts     | posts#index       |
| post  | GET  | posts/:id | posts#show        |
+-------+------+-----------+-------------------+
```

Here's an example with `except`:

```ruby
resources :posts, except: %w[new delete edit update]
```

Results in:

```
+-------+------+-----------+-------------------+
|  As   | Verb |   Path    | Controller#action |
+-------+------+-----------+-------------------+
| posts | GET  | posts     | posts#index       |
| post  | GET  | posts/:id | posts#show        |
|       | POST | posts     | posts#create      |
+-------+------+-----------+-------------------+
```

## 3. Named Routes Helper Methods

Jets automatically generates named routes helper methods from your routes declarations.  Named route helpers are generated for these CRUD-related controller actions: index, new, edit, show.

The **As** column in the previous routes table shows the prefix of the named route helper name. They map to generated named routes helper methods:

As / Prefix | Helper
--- | ---
posts | posts_path
new_post | new_post_path
post | post_path(id)
edit_post | edit_post_path(id)

Named routes helper methods are also generated when you use the `as` option explicitly.

### 3.1 as option

```ruby
get "list", to: "posts#index", as: :list
get "hit", to: "posts#hit" # will not generate a named route helper
get "view/:id", to: "posts#view", as: "view"
```

Generates:

```
+------+------+----------+-------------------+
|  As  | Verb |   Path   | Controller#action |
+------+------+----------+-------------------+
| list | GET  | list     | posts#index       |
|      | GET  | hit      | posts#hit         |
| view | GET  | view/:id | posts#view        |
+------+------+----------+-------------------+
```

Here are their named routes helper methods.

As / Prefix | Helper
--- | ---
list | list_path
view | view_path(id)

### 3.2 member and collection options

Named routes helper methods are also generated when you use the `member` or `collection` keywords with your route.  Refer to the members and collections docs below for examples.

### 3.3 Named routes path and url helper

For each `_path` method there is a corresponding `_url` method.  The `_url` method includes the host. Here's an table with examples:

As / Prefix | Path Helper | Url Helper
--- | --- | ---
posts | posts_path => /posts | posts_url => localhost:8888/posts
new_post | new_post_path => /posts/new | new_post_url => localhost:8888/posts/new
post | post_path(1) => /posts/1 | post_url(1) => localhost:8888/posts/1
edit_post | edit_post_path(1) => /posts/1/edit | edit_post_url(1) => localhost:8888/posts/1/edit

## 4. Singular Resource

There are sometimes resource that always look up the same id. A good example of this is a `profile` resource. The profile resource always looks up the currently logged-in user. We do not need to have the user id as a part of the url path. The singular `resource` is useful here. Example:

```ruby
resource :profile
```

Generates these routes:

```
+--------------+--------+--------------+-------------------+
|      As      |  Verb  |     Path     | Controller#action |
+--------------+--------+--------------+-------------------+
| new_profile  | GET    | profile/new  | profiles#new      |
| profile      | GET    | profile      | profiles#show     |
|              | POST   | profile      | profiles#create   |
| edit_profile | GET    | profile/edit | profiles#edit     |
|              | PUT    | profile      | profiles#update   |
|              | POST   | profile      | profiles#update   |
|              | PATCH  | profile      | profiles#update   |
|              | DELETE | profile      | profiles#delete   |
+--------------+--------+--------------+-------------------+
```

Here are the generated named routes helpers:

As / Prefix | Helper
--- | ---
new_profile | new_profile_path
profile | profile_path
edit_profile | edit_profile_path

There are no arguments for any of the generated helper methods. They are not needed. Also notice, there is no index action route.

## 5. Nested Resources

Nesting resources are supported. Example:

```ruby
resources :posts do
  resources :comments
end
```

Results in:

```
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
```

This makes for nice clean URLs. For example, we can get all the comments that belong to a post with `/posts/1/comments`.

Here are the generated named routes helpers:

As / Prefix | Helper
--- | ---
posts | posts_path
new_post | new_post_path
post | post_path(post_id)
edit_post | edit_post_path(post_id)
post_comments | post_comments_path(post_id)
new_post_comment | new_post_comment_path(post_id)
post_comment | post_comment_path(post_id, id)
edit_post_comment | edit_post_comment_path(post_id, id)

Note: When resources are nested the parent path variable names all become `:post_id`.  This is because path variable siblings must all be the same for API Gateway. More details here: [API Gateway Considerations]({% link _docs/considerations/api-gateway.md %}).

## 6. Resource Members and Collections

Within the resources block you can use the `member` or `collection` options as a shorthand to create additional resource related routes.  Example:

```ruby
resources :posts, only: [] do
  get "preview", on: :member
  get "list", on: :collection
end
```

Generates:

```
+--------------+------+------------------------+-------------------+
|      As      | Verb |          Path          | Controller#action |
+--------------+------+------------------------+-------------------+
| preview_post | GET  | posts/:post_id/preview | posts#preview     |
| list_posts   | GET  | posts/list             | posts#list        |
+--------------+------+------------------------+-------------------+
```

And their corresponding named routes helper methods.

As / Prefix | Helper
--- | ---
preview_post | preview_post_path
list | list_path(id)

If you have multiple routes to add, you can also use the block form of `member` or `resources`:

```ruby
resources :posts, only: [] do
  member do
    get "preview"
  end
  collection do
    get "list"
  end
end
```

Also results in:

```
+--------------+------+------------------------+-------------------+
|      As      | Verb |          Path          | Controller#action |
+--------------+------+------------------------+-------------------+
| preview_post | GET  | posts/:post_id/preview | posts#preview     |
| list_posts   | GET  | posts/list             | posts#list        |
+--------------+------+------------------------+-------------------+
```


## 7. Namespace

Namespacing is also supported.  Unlike nested resources, namespaces do not manage or create any **resource**. For example, there's no `:admin_id` variable. Namespacing is useful for organizing code. Example:

```ruby
namespace :admin do
  resources :posts
end
```

Generates:

```
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
```

Namespacing affects:

1. as helper method name: It adds an `admin` to the names.
2. path: The path gets an `admin` **prefix**
3. controller namespace: The controllers are within an `admin` module.

The `namespace` method uses a more general `scope` method. `namespace` is a `scope` declaration with the `as`, `prefix`, and `module` options set to the `namespace` value.

## 8. Scope

Scope is the more general method in the routes DSL. You can use it to set the `as`, `prefix`, and `module`. Some examples to help explain:

### 8.1 prefix example

```ruby
scope :admin do
  get "posts", to: "posts#index"
end
```

Results in:

```
+-------+------+-------------+-------------------+
|  As   | Verb |    Path     | Controller#action |
+-------+------+-------------+-------------------+
| posts | GET  | admin/posts | posts#index       |
+-------+------+-------------+-------------------+
```

Notice, only the path is affected.  You can also set the scope prefix with a hash option. IE: `scope prefix: :admin`

### 8.2 as example

```ruby
scope(as: :admin) do
  get "posts/:id/edit", to: "posts#edit"
end
```

Results in:

```
+-----------------+--------+----------------+-------------------+
|       As        |  Verb  |      Path      | Controller#action |
+-----------------+--------+----------------+-------------------+
| edit_admin_post | GET    | posts/:id/edit | posts#edit        |
+-----------------+--------+----------------+-------------------+
```

Only the generated helper method is affected.

### 8.3 module example

```ruby
scope(module: :admin) do
  get "posts", to: "posts#index"
end
```

Results in:

```
+-------+------+-------+-------------------+
|  As   | Verb | Path  | Controller#action |
+-------+------+-------+-------------------+
| posts | GET  | posts | admin/posts#index |
+-------+------+-------+-------------------+
```

Only the controller module is affected.

## 9. Helper Host

The named routes `_url` methods, will infer the hostname from the request by default.  If you need to configure it explicitly, then you can with `config.helpers.host`. Example:

```ruby
Jets.application.configure do
  config.helpers.host = "http://example.com:8888" # default is nil, which means it'll be inferred from the request
```

{% include prev_next.md %}
