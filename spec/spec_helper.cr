require "spec"
require "json"
require "../src/marshal"
RAND = Random.new

class Bar
  @foo1 : Int64 = 7
  @foo2 : Float32 = 6.4

  def foo1
    @foo1
  end

  def foo2
    @foo2
  end
end

class Foo
  @bar1 : String = ""
  @bar2 : Int32
  @bar3 : Bar

  def initialize(bar : Bar)
    @bar2 = 3
    @bar3 = bar
  end

  def bar1
    @bar1
  end

  def bar2
    @bar2
  end

  def bar3
    @bar3
  end
end

TEST_BAR = Bar.new
TEST_FOO = Foo.new(TEST_BAR)
