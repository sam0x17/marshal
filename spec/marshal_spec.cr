require "./spec_helper"

describe Marshal do
  it "works with Int32" do
    i = RAND.next_int
    packed = i.marshal_pack
    Int32.marshal_unpack(packed).should eq i
  end
end
