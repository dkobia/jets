class Jets::Router::MethodCreator
  # TODO: Unsure if is this the convention we want?
  # What about when method has arguments? Should calculate number of params
  class Generic < Code
    def meth_name
      join(action, full_as, path_trunk)
    end

    def meth_result
      items = @scope.full_as_meth_args
      return unless items

      result = []
      items.each_with_index do |item, index|
        item = item.to_s
        if index == items.size - 1 # last item
          result << "#{item}/#{action}"
        else
          result << "#{item}/\#{#{param_name(item)}.to_param}"
        end
      end

      "/" + result.join("/")
    end
  end
end
