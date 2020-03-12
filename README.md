# marshal

The purpose of this shard is to provide easy-to-use marshaling of crystal objects
without any work needed on the part of the programmer. There are no modules to
include, simply `require "marshal"` and you can use `obj.marshal_pack` on any
object to pack it into bytes and `Klass.marshal_unpack(bytes)` to unpack any
object that was packed using the library.

Marshal goes to great lengths to try to work out of the box for most types,
but some types will cause it to fail. It is recommended that you write
specs similar to those in the `marshal_spec.cr` file for whatever types
you plan to use before using this.

The shard is under development though the core API will never change. This
is not production stable but with a few specs you can have confidence
it will work in your particular scenario.

This is basically messagepack for the lazy.
