class Jets::Router::MethodCreator
  class Generic < Code
    def meth_name
      underscore(@options[:as])
    end
  end
end
