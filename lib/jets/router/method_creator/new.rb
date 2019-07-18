class Jets::Router::MethodCreator
  class New < Code
    def meth_name
      join(action, singularize(full_as), singularize(path_trunk))
    end

    def meth_result
      items = @scope.full_as_meth_args
      return unless items

      result = []
      items.each_with_index do |item, index|
        item = item.to_s
        if index == items.size - 1 # last item
          result << "#{item}/new"
        else
          result << "#{item}/\#{#{item}.to_param}"
        end
      end

      "/" + result.join("/")
    end
  end
end
