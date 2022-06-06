require "./spec_helper"

describe Parser do
  it "can parse an imperative sentence" do
    input = "nanu ta peli"
    expected = s(v("nanu", mood: Mood::Imperative), [nil, n("peli"), nil])
    parse(input).first.should eq(expected)
  end
end
