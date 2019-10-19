require "./spec_helper"

describe Marshal do
  describe "#marshal_pack" do
    it "works with Int32" do
      1000.times { RAND.next_int.marshal_pack.bytesize.should eq sizeof(Int32) }
    end

    it "works with Int64" do
      1000.times { RAND.next_int.to_i64.marshal_pack.bytesize.should eq sizeof(Int64) }
    end

    it "works with Float32" do
      1000.times { RAND.next_float.to_f32.marshal_pack.bytesize.should eq sizeof(Float32) }
    end

    it "works with Float64" do
      1000.times { RAND.next_float.marshal_pack.bytesize.should eq sizeof(Float64) }
    end

    it "works with Bool" do
      false.marshal_pack.bytesize.should eq 1
      true.marshal_pack.bytesize.should eq 1
    end

    it "works with String" do
      st = "this is a very long string so yeah its pretty cool"
      st.marshal_pack.bytesize.should eq st.bytesize
    end

    it "works with empty String" do
      "".marshal_pack.bytesize.should eq "".bytesize
    end

    it "works with nil" do
      nil.marshal_pack.bytesize.should eq 0
    end
  end

  describe "#marshal_unpack" do
    it "works with Int32" do
      1000.times do
        i = RAND.next_int
        Int32.marshal_unpack(i.marshal_pack).should eq i
      end
    end

    it "works with Int64" do
      1000.times do
        i = RAND.next_int.to_i64
        Int64.marshal_unpack(i.marshal_pack).should eq i
      end
    end

    it "works with Float32" do
      1000.times do
        i = RAND.next_float.to_f32
        Float32.marshal_unpack(i.marshal_pack).should eq i
      end
    end

    it "works with Float64" do
      1000.times do
        i = RAND.next_float
        Float64.marshal_unpack(i.marshal_pack).should eq i
      end
    end

    it "works with Bool" do
      Bool.marshal_unpack(true.marshal_pack).should eq true
      Bool.marshal_unpack(false.marshal_pack).should eq false
    end

    it "works with nil" do
      Nil.marshal_unpack(nil.marshal_pack).should eq nil
    end

    it "works with arbitrary classes" do
      unpacked = Foo.marshal_unpack(TEST_FOO.marshal_pack)
      unpacked.bar1.should eq TEST_FOO.bar1
      unpacked.bar2.should eq TEST_FOO.bar2
      unpacked = unpacked.bar3
      unpacked.foo1.should eq TEST_BAR.foo1
      unpacked.foo2.should eq TEST_BAR.foo2
    end

    it "works on arrays" do
      arr = [1, 3, 4, 7, 4, 2, 6]
      Array(Int32).marshal_unpack(arr.marshal_pack).should eq arr
    end

    it "works on hashes" do
      hash = Hash(String, String).new
      hash["blah"] = "something"
      hash["foo"] = "something else"
      Hash(String, String).marshal_unpack(hash.marshal_pack).should eq hash
    end

    it "works on type unions if we are explicit about what they are" do
      100.times do
        val = union_val
        packed = val.marshal_pack
        klass = if val.is_a?(Int32)
          Int32
        elsif val.is_a?(Int64)
          Int64
        else
          Bool
        end
        unpacked = klass.marshal_unpack(val.marshal_pack)
        unpacked.should eq val
      end
    end

    pending "works with arbitrary JSON::Any" do
      json = JSON.parse(File.read("./spec/test.json"))
      packed = json.marshal_pack
      unpacked = JSON::Any.marshal_unpack(packed)
      unpacked.to_json.should eq json.to_json
    end
  end
end
