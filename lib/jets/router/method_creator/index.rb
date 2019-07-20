class Jets::Router::MethodCreator
  class Index < Code
    def meth_name
      x = join(full_as, path_trunk)
      puts "full_as #{full_as}"
      puts "path_trunk #{path_trunk}"
      puts "x #{x}"
      x
    end
  end
end
