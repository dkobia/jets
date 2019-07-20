module Jets
  class Router
    class Scope
      include Util

      attr_reader :options, :parent, :level
      def initialize(options = {}, parent = nil, level = 1)
        @options = options
        @parent = parent
        @level = level
      end

      def root?
        @parent.nil?
      end

      def new(options={})
        self.class.new(options, self, level + 1)
      end

      def full_module
        items, i = [], 0
        current = self
        while current
          mod = current.options[:module]
          if mod
            case current.from
            when :resources, :resource
              unless i == 0 # since resources and resource create an extra 'scope' layer
                items.unshift(mod)
              end
            else # namespace or scope
              items.unshift(mod)
            end
          end

          current = current.parent
          i += 1
        end
        items.compact!
        return if items.empty?

        items.join('/')
      end

      def full_prefix
        items, i = [], 0
        current = self
        while current
          prefix = current.options[:prefix]
          if prefix
            case current.from
            when :resources, :resource
              # For the last node, we always do not add the path part since the path is already included in the prefix
              # for the resources macro
              if i == 0
                prefix = prefix.to_s.split('/')[0..-2].join('/') # drop the last element
                items.unshift(prefix) unless prefix == ''
              else
                # Drop last items which is the path part because resources can be used with :prefix option.
                # With resources, the prefix option adds the prefix to the resource item name.
                # This creates an name like: `admin/posts`. We only want the posts part.
                variable = prefix.to_s.split('/')[0..-1].last
                variable = ":#{variable.singularize}_id"
                items.unshift(variable)
                items.unshift(prefix)
              end
            else # namespace or scope
              items.unshift(prefix)
            end
          end

          current = current.parent
          i += 1
        end
        items.compact!
        return if items.empty?

        items.join('/')
      end

      def full_as
        items = []
        current = self
        while current
          items.unshift(current.options[:as]) # <= option_name
          current = current.parent
        end

        items.compact!
        return if items.empty?

        items = singularize_leading(items)
        items.join('_')
      end

      # singularize all except last item
      def singularize_leading(items)
        result = []
        items.each_with_index do |item, index|
          item = item.to_s
          r = index == items.size - 1 ? item : item.singularize
          result << r
        end
        result
      end

      def from
        @options[:from]
      end
    end
  end
end
