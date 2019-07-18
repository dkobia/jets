class Jets::Router::MethodCreator
  class Edit < Code
    def meth_name
      join(action, singularize(full_as), singularize(path_trunk))
    end

    def meth_args
      show = Show.new(@options, @scope, @action)
      show.meth_args
    end

    def meth_result
      show = Show.new(@options, @scope, @action)
      show.meth_result + '/edit'
    end
  end
end
