require "action_view"

# hackety hack
module Jets::UrlHelper
  include Jets::CommonMethods

  # Basic implementation of url_for to allow use helpers without routes existence
  def url_for(options = nil) # :nodoc:
    url = case options
          when String
            options
          when :back
            _back_url
          when ActiveRecord::Base
            _handle_model(options)
          else
            raise ArgumentError, "Please provided a String to link_to as the the second argument. The Jets link_to helper takes as the second argument."
          end

    add_stage_name(url)
  end

  def _handle_model(record)
    model = record.to_model
    if model.persisted?
      meth = model.model_name.singular_route_key + "_path"
      send(meth, record) # Example: post_path(record)
    else
      meth = model.model_name.route_key + "_path"
      send(meth) # Example: posts_path
    end
  end
end # UrlHelper

ActionView::Helpers.send(:include, Jets::UrlHelper)
