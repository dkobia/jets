class Jets::Router::MethodCreator
  class Index < Code
    def meth_name
      join(full_as, path_trunk)
    end

    def meth_args
      items = walk_scope_parents do |current, i, result|
        prefix = current.options[:prefix]
        next unless prefix

        case current.from
        when :resources
          # unless i == 0 because index action doesnt have parameter at the end
          result.unshift(param_name(prefix)) unless i == 0
        else # namespace or scope
          # do nothing
        end
      end

      items.empty? ? nil : "("+items.join(', ')+")"
    end

    def meth_result
      puts "options: #{@options}".color(:orange)
      puts "@path #{@path}"
      puts "path_trunk #{path_trunk.inspect}"
      # pp @scope

      items = walk_scope_parents do |current, i, result|
        puts "current.level options #{current.level}:".color(:green)
        pp current.options

        prefix = current.options[:prefix]

        # Case: scope(as: "admin") and no prefix is set, then we'll use the trunk path for end of the path
        if !prefix && i == 0
          result.unshift(path_trunk)
          next
        end

        # if current.from != :resources # wont have prefix
        # end
        # if !prefix

        next unless prefix

        case current.from
        when :resources
          if i == 0 # index action doesnt have parameter at the end
            # TODO: figure this out
            # trunk = @path.to_s.split('/').first
            # result.unshift(trunk)
            ##
            result.unshift(prefix)
          else
            param = param_name(prefix)
            result.unshift("#{prefix}/\#{#{param}.to_param}")
          end
        else # namespace or scope
          result.unshift(prefix)
        end
      end

      items.empty? ? nil : '/' + items.join('/')
    end
  end
end
