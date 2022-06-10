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
    input = "besani file lefi sanai peli keze"
    expected = s(v("sanai", m("lefi", n("besani", "file"))), [n("peli", "keze"), nil, nil])
    Parser.parse(input).should eq([expected])
  end

  it "can parse a sentence with a clause" do
    input = "kuino bova lefi sanai moresa si pena"
    expected = s(v("sanai", m("lefi", n("kuino", "bova"))), [n("moresa", si: s(v("pena"))), nil, nil])
    Parser.parse(input).should eq([expected])
  end

  it "can parse a sentence with a noun attribute" do
    input = "kuna me ni gata ta kena temirana vi"
    expected = s(v!("gata", m("ni", n("kuna", "me"))), [nil, n("kena", "temirana", attr: [:vi]), nil])
    Parser.parse(input).should eq([expected])
  end
end
