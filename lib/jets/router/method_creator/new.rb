class Jets::Router::MethodCreator
  class New < Code
    def meth_name
      join(action, singularize(full_as), singularize(path_trunk))
    end
  end
end
