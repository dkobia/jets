---
title: Routing Guide
---

This is a thorough guide of how Jets Routing works.

## 1. Introduction

## 2. Resources

## 3. Named Routes Helper Methods

Named routes helper methods are generated from your routes declarations.  Named route helpers are generated for these CRUD methods: index, new, edit, show.  For example:

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

The as column shows the prefix of the named route helper name.

As / Prefix | Helper
--- | ---
posts | posts_path
new_post | new_post_path
post | post_path(id)
edit_post | edit_post_path(id)

Named routes helper methods are also generated when you use the `as` option.  Example:

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

As / Prefix | Helper
--- | ---
list | list_path
view  | view_path(id)

By convention, named routes are not generated for every single one of your route declarations. If they were generated for every route declaration, Jets would have to probably use the path as a way to avoid method name collisions. Often, this leads to long helper method names that are hard to remember.

## 3. Singular Resource

## 4. Namespace

## 5. Nested Resources

Nested resources are supported:

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


{% include prev_next.md %}