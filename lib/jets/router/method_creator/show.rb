class Jets::Router::MethodCreator
  class Show < Code
    def meth_name
      join(singularize(full_as), singularize(path_trunk))
    end

    def meth_result
      items = @scope.full_as_meth_args
      return unless items

      result = items.map do |x|
        "#{x}/\#{#{param_name(x)}.to_param}"
      end.join('/')
      "/#{result}"
    end
  end
end
