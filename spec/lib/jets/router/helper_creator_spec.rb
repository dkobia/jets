class HelperCreaterView
  include Jets::RoutesHelper
end

describe Jets::Router::HelperCreator do
  let(:creator) { Jets::Router::HelperCreator.new(options) }
  let(:view)    { HelperCreaterView.new }

  context "posts" do
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

  context "admin/posts" do
    context "admin_posts_path" do
      let(:options) do
        { to: "admin/posts#index", path: "api/v1/posts", method: :get }
        { to: "admin/posts#index", path: "admin/posts", method: :get }
      end
      it "method" do
        # meths1 = Jets::RoutesHelper.public_instance_methods - Object.methods
        creator.define_url_helpers!
        # meths = Jets::RoutesHelper.public_instance_methods - meths1
        # puts(meths.sort)
        expect(view.admin_posts_path).to eq "/admin/posts"
      end
    end

    context "new_admin_post_path" do
      let(:options) do
        { to: "admin/posts#new", path: "admin/posts/new", method: :get }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.new_admin_post_path).to eq "/admin/posts/new"
      end
    end

    context "admin_post_path" do
      let(:options) do
        { to: "admin/posts#show", path: "admin/posts/:id", method: :get }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.admin_post_path(1)).to eq "/admin/posts/1"
      end
    end

    context "edit_admin_post_path" do
      let(:options) do
        { to: "admin/posts#edit", path: "admin/posts/:id/edit", method: :get }
      end
      it "method" do
        creator.define_url_helpers!
        expect(view.edit_admin_post_path(1)).to eq "/admin/posts/1/edit"
      end
    end
  end
end