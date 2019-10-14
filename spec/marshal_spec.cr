require "./spec_helper"

describe Marshal do
  it "works with Int32" do
    i = RAND.next_int
    packed = Marshal(Int32).pack(i)
    Marshal(Int32).unpack(packed).should eq i
  end
end
