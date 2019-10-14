module Marshal
  macro included
    def pack_bytes
      \{% if @type.ancestors.includes?(Value) %}
        data = Bytes.new sizeof(\{{@type}})
        ptr = self.unsafe_as(StaticArray(UInt8, sizeof(\{{@type}})))
        sizeof(\{{@type}}).times { |i| data[i] = ptr[i] }
        return data
      \{% else %}
        mem = IO::Memory.new
        \{% for var in @type.instance_vars %}
          mem.write(@\{{var}}.pack_bytes)
        \{% end %}
        return mem.to_slice
      \{% end %}
    end

    def self.unpack_bytes(data : Bytes)
      puts \{{@type}}
      \{% if @type == Object %}
        return Object.new
      \{% elsif @type.ancestors.includes?(Value) %}
        obj = StaticArray(UInt8, sizeof(\{{@type}})).new(0)
        sizeof(\{{@type}}).times { |i| obj[i] = data[i] }
        puts "sizeof: #{sizeof(\{{@type}})}, data.size: #{data.size}"
        return obj.unsafe_as(\{{@type}})
      \{% else %}
        obj = StaticArray(UInt8, sizeof(\{{@type}})).new(0).unsafe_as(\{{@type}})
        cursor = 0
        \{% for var in @type.instance_vars %}
          child = typeof(obj.@\{{var}}).unpack_bytes(data[cursor..sizeof(typeof(obj.@\{{var}}))])
          obj.marshal_force_write_\{{var}} = child
          cursor += sizeof(typeof(obj.@\{{var}}))
        \{% end %}
        return obj
      \{% end %}
    end
  end
end

abstract class Object
  include Marshal
end

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
#`pp! obj
#bytes = Dumper(Foo).dump_object(obj)
#pp! bytes
#duplicate = Dumper(Foo).from_dump(bytes)
#pp! duplicate

obj.marshal_force_write_something = 32

#puts obj.pack_bytes
#puts "|#{Foo.unpack_bytes(obj.pack_bytes)}|"
