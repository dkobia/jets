class Jets::Router::MethodCreator
  class Show
    include Jets::Router::Util

    def initialize()
      @code = Code.new
    end

    def create
      as = @options[:as] || @code.meth_name
      meth_name = underscore("#{as}_path")
      meth_args = @code.meth_args
      meth_result = @code.meth_result

      code =<<~EOL
        def #{meth_name}#{meth_args}
          "#{meth_result}"
        end
      EOL
      puts code
      def_meth code
    end
  end
end
