class Jets::Router::MethodCreator
  class Edit < Code
    def meth_name
      join(action, singularize(full_as), singularize(path_trunk))
    end

    def meth_result
      items = @scope.full_as_meth_args
      return unless items

      result = items.map do |x|
        "#{x}/\#{#{param_name(x)}.to_param}"
      end.join('/')
      "/#{result}/edit"
    end
  end
end
