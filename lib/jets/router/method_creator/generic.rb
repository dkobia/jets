class Jets::Router::MethodCreator
  class Generic < Code
    def meth_name
      puts "@options[:as] #{@options[:as]}"
      underscore(@options[:as])
    end
  end
end
