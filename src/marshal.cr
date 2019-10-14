class Foo  
  def initialize(@something : Int32, @something_else : Int64, @thing : Int32, @thing2 : Int32)
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
          mem.write(@\{{var}}.marshal_pack)
        \{% end %}
        mem.to_slice
      \{% end %}
    end

    def self.marshal_unpack(bytes : Bytes)
      \{% if @type.ancestors.includes?(Value) %}
        ptr = StaticArray(UInt8, sizeof(\{{@type}})).new(0)
        bytes.each_with_index { |byte, i| ptr[i] = byte }
        ptr.unsafe_as(\{{@type}})
      \{% else %}
        obj = Pointer(UInt8).malloc(safe_sizeof(\{{@type}})).unsafe_as(\{{@type}})
        mem = IO::Memory.new(bytes)
        \{% for var in @type.instance_vars %}
          slice = Bytes.new(safe_sizeof(\{{var.type}}))
          mem.read(slice)
          value = \{{var.type}}.marshal_unpack(slice)
          obj.force_write!(:\{{var}}, value)
        \{% end %}
        obj
      \{% end %}
    end
  end
end

abstract class Object
  include Marshal
end

obj = Foo.new(31, 33_i64, 13, 17)

pp! 3.marshal_pack
pp! Int32.marshal_unpack(3.marshal_pack)
pp! 37987_i64.marshal_pack
pp! "hello this is a very long string so yeah".marshal_pack
pp! obj
obj_packed = obj.marshal_pack
pp! obj_packed
obj_unpacked = Foo.marshal_unpack(obj_packed)
pp! obj_unpacked
