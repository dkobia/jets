class Jets::Router
  module Util
    # used in AsOption
    def join(*items)
      list = items.compact.join('_')
      underscore(list)
    end

    def underscore(str)
      return unless str
      str.gsub('-','_').gsub('/','_')
    end
  end
end