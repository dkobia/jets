class Jets::Router
  class ResourcesOptions
    def initialize(name, options)
      @name, @options = name, options
    end

    def build(action)
      @options.merge(to: "#{@name}##{action}")
    end
  end
end
