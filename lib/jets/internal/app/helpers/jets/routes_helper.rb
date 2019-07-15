module Jets::RoutesHelper
  # Used for form_for helper
  def polymorphic_path(record, _)
    url_for(record)
  end
end
