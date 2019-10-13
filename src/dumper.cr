class Foo  
  def initialize(@something : Int32, @something_else : Int64, @thing : Int32, @thing2 : Int32, @str : String)
  end
end

module Dumper(T)
  def self.dump_object(obj) : Bytes
    data = Bytes.new(instance_sizeof(T))
    ptr = obj.as(UInt8*)
    instance_sizeof(T).times { |i| data[i] = ptr[i] }
    data
  end

  def self.from_dump(bytes : Bytes)
    raise "invalid number of bytes" unless bytes.size == instance_sizeof(T)
    ptr = Pointer(UInt8).malloc(instance_sizeof(T))
    bytes.each_with_index { |byte, i| ptr[i] = byte }
    ptr.as(T)
  end
end

obj = Foo.new(31, 33_i64, 13, 17, "hey this is a really really long string ok it is long so yeah and it definitely could not fit in this tiny thing")
pp! obj
bytes = Dumper(Foo).dump_object(obj)
pp! bytes
duplicate = Dumper(Foo).from_dump(bytes)
pp! duplicate
