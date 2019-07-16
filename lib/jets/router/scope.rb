module Jets
  class Router
    class Scope
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
        ns = []
        current = self
        while current
          ns.unshift(current.options[:module])
          current = current.parent
        end
        ns.empty? ? nil : ns.join('/')
      end

      # TODO: remove duplication: full_prefix vs full_module
      def full_prefix
        items = []
        current = self
        while current
          items.unshift(current.options[:prefix])
          current = current.parent
        end
        items.empty? ? nil : items.join('/')
      end
    end
  end
end
