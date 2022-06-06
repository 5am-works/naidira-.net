require "./spec_helper"

include Naidira

describe Parser do
  it "can parse an imperative sentence" do
    [
      {"nanu ta peli", s(v!("nanu"), [nil, n("peli"), nil])},
      {"moro ta romi", s(v!("moro"), [nil, n("romi"), nil])},
    ].each do |(input, expected)|
      Parser.parse(input).first.should eq(expected)
    end
  end

  it "can parse a sentence with a verb modifier" do
    input = "lefi besani file sanai peli keze"
    expected = s(v("sanai", m("lefi", n("besani", "file"))), [n("peli", "keze"), nil, nil])
    Parser.parse(input).first.should eq(expected)
  end
end
