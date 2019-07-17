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

      def full(option_name)
        items = []
        current = self
        while current
          items.unshift(current.options[option_name]) # <= option_name
          current = current.parent
        end
        items.compact!
        items.empty? ? nil : items.join('/')
      end
    end
  end
end
