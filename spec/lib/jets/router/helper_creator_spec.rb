class HelperCreaterView
  include Jets::RoutesHelper
end

describe Jets::Router::HelperCreator do
  let(:creator) { Jets::Router::HelperCreator.new(options) }
  let(:view)    { HelperCreaterView.new }

  context "top-level" do
    context "posts_path" do
      let(:options) do
        { to: "posts#index", path: "posts", method: :get }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.posts_path).to eq "/posts"
      end
    end

    context "new_post_path" do
      let(:options) do
        { to: "posts#new", path: "posts/new", method: :get }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.new_post_path).to eq "/posts/new"
      end
    end

    context "post_path" do
      let(:options) do
        { to: "posts#show", path: "posts/:id", method: :get }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.post_path(1)).to eq "/posts/1"
      end
    end

    context "edit_post_path" do
      let(:options) do
        { to: "posts#edit", path: "posts/:id/edit", method: :get }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.edit_post_path(1)).to eq "/posts/1/edit"
      end
    end
  end

  # namespace :admin do
  #   get "posts", to "posts#index"
  # end
  context "namespace admin" do
    context "admin_posts_path" do
      let(:options) do
        { to: "posts#index", path: "posts", method: :get, module: "admin", prefix: "admin", as: "admin_posts" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.admin_posts_path).to eq "/admin/posts"
      end
    end

    context "new_admin_post_path" do
      let(:options) do
        { to: "posts#new", path: "posts/new", method: :get, module: "admin", prefix: "admin", as: "new_admin_post" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.new_admin_post_path).to eq "/admin/posts/new"
      end
    end

    context "admin_post_path" do
      let(:options) do
        { to: "posts#show", path: "posts/:id", method: :get, module: "admin", prefix: "admin", as: "admin_post" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.admin_post_path(1)).to eq "/admin/posts/1"
      end
    end

    context "edit_admin_post_path" do
      let(:options) do
        { to: "posts#edit", path: "posts/:id/edit", method: :get, module: "admin", prefix: "admin", as: "edit_admin_post" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.edit_admin_post_path(1)).to eq "/admin/posts/1/edit"
      end
    end
  end

  # namespace "api/v1" do
  #   get "posts", to "posts#index"
  # end
  context "namespace api/v1" do
    context "api_v1_posts_path" do
      let(:options) do
        { to: "posts#index", path: "posts", method: :get, module: "api/v1", prefix: "api/v1", as: "api_v1_posts" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.api_v1_posts_path).to eq "/api/v1/posts"
      end
    end

    context "new_api_v1_post_path" do
      let(:options) do
        { to: "posts#new", path: "posts/new", method: :get, module: "api/v1", prefix: "api/v1", as: "new_api_v1_post" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.new_api_v1_post_path).to eq "/api/v1/posts/new"
      end
    end

    context "api_v1_post_path" do
      let(:options) do
        { to: "posts#show", path: "posts/:id", method: :get, module: "api/v1", prefix: "api/v1", as: "api_v1_post" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.api_v1_post_path(1)).to eq "/api/v1/posts/1"
      end
    end

    context "edit_api_v1_post_path" do
      let(:options) do
        { to: "posts#edit", path: "posts/:id/edit", method: :get, module: "api/v1", prefix: "api/v1", as: "edit_api_v1_post" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.edit_api_v1_post_path(1)).to eq "/api/v1/posts/1/edit"
      end
    end
  end

  # scope "api/v1" do
  #   get "posts", to "posts#index"
  # end
  #
  # scope prefix: "api/v1" do
  #   get "posts", to "posts#index"
  # end
  context "scope api/v1" do
    context "posts_path" do
      let(:options) do
        { to: "posts#index", path: "posts", method: :get, prefix: "api/v1" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.posts_path).to eq "/api/v1/posts"
      end
    end

    context "new_post_path" do
      let(:options) do
        { to: "posts#new", path: "posts/new", method: :get, prefix: "api/v1" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.new_post_path).to eq "/api/v1/posts/new"
      end
    end

    context "post_path" do
      let(:options) do
        { to: "posts#show", path: "posts/:id", method: :get, prefix: "api/v1" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.post_path(1)).to eq "/api/v1/posts/1"
      end
    end

    context "edit_post_path" do
      let(:options) do
        { to: "posts#edit", path: "posts/:id/edit", method: :get, prefix: "api/v1" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.edit_post_path(1)).to eq "/api/v1/posts/1/edit"
      end
    end
  end

  # scope module: "api/v1" do
  #   get "posts", to "posts#index"
  # end
  context "scope api/v1" do
    context "posts_path" do
      let(:options) do
        { to: "posts#index", path: "posts", method: :get, module: "api/v1" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.posts_path).to eq "/posts"
      end
    end

    context "new_post_path" do
      let(:options) do
        { to: "posts#new", path: "posts/new", method: :get, module: "api/v1" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.new_post_path).to eq "/posts/new"
      end
    end

    context "post_path" do
      let(:options) do
        { to: "posts#show", path: "posts/:id", method: :get, module: "api/v1" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.post_path(1)).to eq "/posts/1"
      end
    end

    context "edit_post_path" do
      let(:options) do
        { to: "posts#edit", path: "posts/:id/edit", method: :get, module: "api/v1" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.edit_post_path(1)).to eq "/posts/1/edit"
      end
    end
  end

  # scope as: "api/v1" do
  #   get "posts", to "posts#index"
  # end
  context "scope api/v1" do
    context "api_v1_posts_path" do
      let(:options) do
        { to: "posts#index", path: "posts", method: :get, as: "api_v1_posts" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.api_v1_posts_path).to eq "/posts"
      end
    end

    context "new_api_v1_post_path" do
      let(:options) do
        { to: "posts#new", path: "posts/new", method: :get, as: "new_api_v1_post" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.new_api_v1_post_path).to eq "/posts/new"
      end
    end

    context "api_v1_post_path" do
      let(:options) do
        { to: "posts#show", path: "posts/:id", method: :get, as: "api_v1_post" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.api_v1_post_path(1)).to eq "/posts/1"
      end
    end

    context "edit_api_v1_post_path" do
      let(:options) do
        { to: "posts#edit", path: "posts/:id/edit", method: :get, as: "edit_api_v1_post" }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.edit_api_v1_post_path(1)).to eq "/posts/1/edit"
      end
    end
  end

  context "url with dash" do
    let(:options) do
      { to: "posts#index", path: "url-with-dash", method: :get }
    end
    it "method" do
      creator.define_url_helpers!
      expect(view.url_with_dash_path).to eq "/url-with-dash"
    end
  end
end

