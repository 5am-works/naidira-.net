require "./spec_helper"

include Naidira

describe Lexer do
  it "can lexicalize arguments" do
    input = ["peli", "romi"]
    expected = [n("peli", "romi")]
    Parser.lexicalize(input).should eq(expected)
  end
end
