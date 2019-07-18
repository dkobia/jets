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
          leaf = current.options[:module]
          if leaf
            case current.from
            when :resources
              unless i == 0 # since resources creates an extra layer
                items.unshift(leaf)
              end
            else # namespace or scope
              items.unshift(leaf)
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
          leaf = current.options[:prefix]
          if leaf
            case current.from
            when :resources
              unless i == 0 # since resources creates an extra layer
                items.unshift(":#{leaf.to_s.singularize}_id")
                items.unshift(leaf)
              end
            else # namespace or scope
              items.unshift(leaf)
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
          # puts "scope.rb current as #{current.level} #{current}".color(:yellow)
          # pp current
          items.unshift(current.options[:as]) # <= option_name
          current = current.parent
        end
        items.compact!
        return if items.empty?

        items = singularize_leading(items)
        items.join('_')
      end

      def full_as_meth_args
        items = []
        current = self
        while current
          leaf = current.options[:as]
          items.unshift(leaf) if leaf
          current = current.parent
        end
        items.empty? ? nil : items
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
