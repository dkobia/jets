class Jets::Router::MethodCreator
  class Show < Code
    def meth_name
      join(singularize(full_as), singularize(path_trunk))
    end
  end
end
