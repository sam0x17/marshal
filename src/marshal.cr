class Foo  
  def initialize(@something : Int32, @something_else : Int64, @thing : Int32, @thing2 : Int32, @str : String)
  end
end

module Marshal
  macro safe_sizeof(type)
    {% if type.resolve.ancestors.includes?(Value) %}
      sizeof({{type}})
    {% else %}
      instance_sizeof({{type}})
    {% end %}
  end

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

    def marshal_pack
      return Bytes.new(0) if safe_sizeof(\{{@type}}) == 0
      \{% if @type.ancestors.includes?(Value) %}
        data = Bytes.new(safe_sizeof(\{{@type}}))
        ptr = self.unsafe_as(StaticArray(UInt8, sizeof(\{{@type}})))
        safe_sizeof(\{{@type}}).times { |i| data[i] = ptr[i] }
        data
      \{% else %}
        mem = IO::Memory.new
        \{% for var in @type.instance_vars %}
          mem.write(obj.@\{{var}}.marshal_pack)
        \{% end %}
        mem.to_slice
      \{% end %}
    end

    def self.marshal_unpack(bytes : Bytes)
      \{% if @type == Nil %}
        return nil
      \{% elsif @type.ancestors.includes?(Value) %}
        ptr = Pointer(UInt8).malloc(safe_sizeof(\{{@type}}))
        bytes.each_with_index { |byte, i| ptr[i] = byte }
        ptr.unsafe_as(\{{@type}})
      \{% else %}
        obj = Pointer(Uint8).malloc(safe_sizeof(\{{@type}})).unsafe_as(\{{@type}})
        cursor = 0
        \{% for var in @type.instance_vars %}
          value = \{{var.type}}.marshal_unpack(bytes[cursor..(cursor + safe_sizeof(\{{var.type}}))])
          obj.force_write!(:\{{var}}, value)
          cursor += safe_sizeof(\{{var.type}})
        \{% end %}
      \{% end %}
    end
  end
end

abstract class Object
  include Marshal
end

obj = Foo.new(31, 33_i64, 13, 17, "hey this is a really really long string ok it is long so yeah and it definitely could not fit in this tiny thing")

pp! 3.marshal_pack
pp! Int32.marshal_unpack(3.marshal_pack)
pp! 37987_i64.marshal_pack
#pp! Marshal(String).pack("hello this is a very long string so yeah")
#pp!(obj = Marshal(Foo).pack(obj))
