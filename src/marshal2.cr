require "json"

module Marshal
  macro is_ref?(t)
    {{t.resolve.ancestors.includes?(Reference)}}
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
      \{% for var in @type.instance_vars %}

      \{% end %}
    end

    def marshal_encode()
  end
end

abstract class Object
  include Marshal
end
