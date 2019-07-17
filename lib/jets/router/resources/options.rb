module Jets::Router::Resources
  class Options < Base
    def build(action)
      @options.merge(to: "#{@name}##{action}")
    end
  end
end
