class Jets::Router::MethodCreator
  class Index < Code
    def meth_name
      join(full_as, path_trunk)
    end

    def meth_args
      i, items, current = 0, [], @scope
      while current
        prefix = current.options[:prefix]
        if prefix
          case current.from
          when :resources
            # unless i == 0 because index action doesnt have parameter at the end
            items.unshift(param_name(prefix)) unless i == 0
          else # namespace or scope
            # do nothing
          end
        end

        current = current.parent
        i += 1
      end

      items.empty? ? nil : "("+items.join(', ')+")"
    end

    def meth_result
      i, items, current = 0, [], @scope
      while current
        prefix = current.options[:prefix]
        if prefix
          case current.from
          when :resources
            if i == 0 # index action doesnt have parameter at the end
              items.unshift(prefix)
            else
              param = param_name(prefix)
              items.unshift("#{prefix}/\#{#{param}.to_param}")
            end
          else # namespace or scope
            items.unshift(prefix)
          end
        end

        current = current.parent
        i += 1
      end

      items.empty? ? nil : '/' + items.join('/')
    end
  end
end
