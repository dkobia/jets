class Jets::Router::MethodCreator
  class Show < Code
    def meth_name
      join(singularize(full_as), singularize(path_trunk))
    end

    # Example return values:
    #
    #     post_comment_path => (post_id, comment_id)
    #     post_path => (post_id)
    #
    def meth_args
      items = walk_scope_parents do |current, i, result|
        prefix = current.options[:prefix]
        next unless prefix

        case current.from
        when :resources
          result.unshift(param_name(prefix))
        else # namespace or scope
          # do nothing
        end
      end

      items.empty? ? nil : "("+items.join(', ')+")"
    end

    def meth_result
      items = walk_scope_parents do |current, i, result|
        prefix = current.options[:prefix]

        # Case: scope(as: "admin") and no prefix is set, then we'll use the trunk path for end of the path
        if !prefix && i == 0
          result.unshift(path_trunk)
          next
        end

        next unless prefix

        case current.from
        when :resources
          param = param_name(prefix)
          result.unshift("#{prefix}/\#{#{param}.to_param}")
        else # namespace or scope
          result.unshift(prefix)
        end
      end

      items.empty? ? nil : '/' + items.join('/')
    end
  end
end
