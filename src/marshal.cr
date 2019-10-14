class Foo  
  def initialize(@something : Int32, @something_else : Int64, @thing : Int32, @thing2 : Int32, @str : String)
  end
end

module ForceWriter
  macro included
    def force_write!(name : Symbol, value)
      \{% if true %}
      case name
      \{% for var in @type.instance_vars %}
        when :\{{var}}
          puts "about to unsafely cast #{value} (#{typeof(value)}) to #{\{{var.type}}}"
          @\{{var}} = value.unsafe_as(\{{var.type}})
      \{% end %}
      else
        raise "invalid name #{name}"
      end
      \{% end %}
    end
  end
end

abstract class Object
  include ForceWriter
end

module Marshal(T)
  macro safe_sizeof(type)
    {% if type.resolve.ancestors.includes?(Value) %}
      sizeof({{type}})
    {% else %}
      instance_sizeof({{type}})
    {% end %}
  end

  def self.unpack(bytes : Bytes)
    return nil if T == Nil
    if T.is_a?(Value)
      ptr = Pointer(UInt8).malloc(safe_sizeof(T))
      bytes.each_with_index { |byte, i| ptr[i] = byte }
      ptr.unsafe_as(T)
    else
      obj = Pointer(UInt8).malloc(safe_sizeof(T)).unsafe_as(T)
      cursor = 0
      {% for var in T.instance_vars %}
        puts "yay"
        value = {{var.type}}.unpack_bytes(bytes[cursor..(cursor + safe_sizeof({{var.type}}))])
        obj.force_write!(:{{var}}, value)
        cursor += safe_sizeof({{var.type}})
      {% end %}
    end
  end

  def self.pack(obj)
    return Bytes.new(0) if safe_sizeof(T) == 0
    if T.is_a?(Value)
      data = Bytes.new(safe_sizeof(T))
      ptr = obj.unsafe_as(StaticArray(UInt8, sizeof(T)))
      safe_sizeof(T).times { |i| data[i] = ptr[i] }
      data
    else
      mem = IO::Memory.new
      {% for var in T.instance_vars %}
        puts "yay"
        mem.write(Marshal(\{{var.type}}).pack(obj.@{{var}}))
      {% end %}
      mem.to_slice
    end
  end
end

obj = Foo.new(31, 33_i64, 13, 17, "hey this is a really really long string ok it is long so yeah and it definitely could not fit in this tiny thing")

pp! Marshal(Int32).pack(127)
pp! Marshal(Int32).unpack(Marshal(Int32).pack(127))
pp! Marshal(Int64).pack(37987_i64)
#pp! Marshal(String).pack("hello this is a very long string so yeah")
#pp!(obj = Marshal(Foo).pack(obj))
