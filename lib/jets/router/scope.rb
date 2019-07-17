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

      # Examples:
      #
      #     scope.full(:module)
      #     scope.full(:prefix)
      #     scope.full(:as)
      #
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

      # Means the as option comes from within a resource declaration
      #
      #     resources :posts, as: 'images'
      #
      # Use this flag in the AsOption builder to disregard the @path_trunk
      def resources?
        @options[:resources]
      end
    end
  end
end
