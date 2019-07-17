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

        # TODO: REMOVE THIS MESSY DUPLICATION
        if option_name == :prefix
          if namespace?
            items = items[0..-2] || []
          elsif resources?
            items = expand_items(items)
            items = items[0..-3] || []
          else
            puts "UNSURE IF WE'LL GET HERE"
          end
        end

        if option_name == :module
          if namespace?
            items = items[0..-2] || []
          end
        end

        return if items.empty?

        if option_name == :as
          items = singularize_leading(items)
          items.join('_')
        else
          items.join('/')
        end
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

      def expand_items(items)
        result = []
        items.each do |i|
          result << i
          result << ":#{i.to_s.singularize}_id"
        end
        result
      end

      # Means the as option comes from within a resource declaration
      #
      #     resources :posts, as: 'images'
      #
      # Use this flag in the AsOption builder to disregard the @path_trunk
      def resources?
        @options[:resources]
      end

      def namespace?
        @options[:namespace]
      end
    end
  end
end
