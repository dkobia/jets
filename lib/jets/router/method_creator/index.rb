class Jets::Router::MethodCreator
  class Index < Code
    def meth_name
      join(full_as, path_trunk)
    end
  end
end
