class Jets::Router::MethodCreator
  class Index < Code
    def meth_name
      join(full_as, path_trunk)
    end

    def meth_args
      items = @scope.full_as_meth_args
      return unless items

      items.map! {|x| param_name(x) }
      items.pop # remove the last element
      return if items.empty?

      "("+items.join(', ')+")"
    end

    def meth_result
      items = @scope.full_as_meth_args
      return unless items

      result = []
      items.each_with_index do |item, index|
        item = item.to_s
        if index == items.size - 1 # last item
          result << "#{item}"
        else
          result << "#{item}/\#{#{param_name(item)}.to_param}"
        end
      end

      "/" + result.join("/")
    end
  end
end
