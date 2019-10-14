macro safe_sizeof(type)
  {% if type.resolve.ancestors.includes?(Value) %}
    sizeof({{type}})
  {% else %}
    instance_sizeof({{type}})
  {% end %}
end

module MarshalValue
  macro included
    def raw_bytes
      \{% if @type == Bool %}
        return Bytes[0] if self == false
        Bytes[1]
      \{% else %}
        data = Bytes.new(sizeof(\{{@type}}))
        ptr = self.unsafe_as(StaticArray(UInt8, sizeof(\{{@type}})))
        sizeof(\{{@type}}).times { |i| data[i] = ptr[i] }
        data
      \{% end %}
    end

    def self.from_raw_bytes(bytes : Bytes)
      \{% if @type == Bool %}
        return true if bytes == Bytes[1]
        false
      \{% else %}
        ptr = StaticArray(UInt8, sizeof(\{{@type}})).new(0)
        bytes.each_with_index { |byte, i| ptr[i] = byte }
        ptr.unsafe_as(\{{@type}})
      \{% end %}
    end
  end
end

abstract struct Value
  include MarshalValue
end

module Marshal
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
      \{% if @type.ancestors.includes?(Value) %}
        self.raw_bytes
      \{% elsif @type == String %}
        self.to_slice
      \{% else %}
        mem = IO::Memory.new
        \{% for var in @type.instance_vars %}
          value = @\{{var}}.marshal_pack
          mem.write(value.bytesize.raw_bytes)
          mem.write(value)
        \{% end %}
        mem.to_slice
      \{% end %}
    end

    def self.marshal_unpack(bytes : Bytes)
      \{% if @type.ancestors.includes?(Value) %}
        \{{@type}}.from_raw_bytes(bytes)
      \{% elsif @type == String %}
        String.new(bytes)
      \{% else %}
        obj = Pointer(UInt8).malloc(safe_sizeof(\{{@type}})).unsafe_as(\{{@type}})
        mem = IO::Memory.new(bytes)
        \{% for var in @type.instance_vars %}
          bytesize_slice = Bytes.new(sizeof(Int32))
          mem.read(bytesize_slice)
          bytesize = Int32.from_raw_bytes(bytesize_slice)
          value_slice = Bytes.new(bytesize)
          mem.read(value_slice)
          value = \{{var.type}}.marshal_unpack(value_slice)
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
