class Jets::Controller
  module ForgeryProtection
    extend ActiveSupport::Concern

    included do
      config = Jets.config
      default_protect_from_forgery = config.dig(:controllers, :default_protect_from_forgery)
      if default_protect_from_forgery
        protect_from_forgery
      end
    end

    class_methods do
      def protect_from_forgery
        before_action :verify_authenticity_token
      end

      def skip_forgery_protection(options = {})
        skip_before_action :verify_authenticity_token, options
      end

      def forgery_protection_enabled?
        # Example:
        #
        #    before_actions [[:verify_authenticity_token, {}], [:set_post, {:only=>[:show, :edit, :update, :delete]}
        #
        before_actions.map { |a| a[0] }.include?(:verify_authenticity_token)
      end
    end

    # Instance methods
    def verify_authenticity_token
      return true if ENV['TEST'] || request.get? || request.head?

      verified = params[:authenticity_token] == session[:authenticity_token] ||
                 request.headers["x-csrf-token"] == session[:authenticity_token]

      unless verified
        raise Error::InvalidAuthenticityToken
      end
    end
  end
end
