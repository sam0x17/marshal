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
  end
end
