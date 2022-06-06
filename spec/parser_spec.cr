require "./spec_helper"

describe Parser do
  it "can parse an imperative sentence" do
    [
      {"nanu ta peli", s(v!("nanu"), [nil, n("peli"), nil])},
      {"moro ta romi", s(v!("moro"), [nil, n("romi"), nil])},
    ].each do |(input, expected)|
      parse(input).first.should eq(expected)
    end
  end
end
