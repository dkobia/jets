class Jets::Router::MethodCreator
  class New < Code
    def meth_name
      join(action, singularize(full_as), singularize(path_trunk))
    end

    def meth_args
      index = Index.new(@options, @scope, @action)
      index.meth_args
    end

    def meth_result
      index = Index.new(@options, @scope, @action)
      [index.meth_result, 'new'].compact.join('/')
    end
  end
end
