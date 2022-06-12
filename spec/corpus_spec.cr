require "./spec_helper"

include Naidira

describe Parser do
  it "can parse Silika's Sleepsong" do
    text = <<-TEXT
    levi ti bome
    leimi ti mara
    romi ti nori
    mailomi gemi rita

    vele ki tuiri
    ne vele ki meina
    ne vele polini rita leimina
    TEXT
    expected = [
      s(v!("bome"), [nil, n("levi")]),
      s(v!("mara"), [nil, n("leimi")]),
      s(v!("nori"), [nil, n("romi")]),
      s(v("gemi", tense: Tense::Complete), [n("mailomi"), nil]),

      s(v("ki"), [n("vele"), n("tuiri")]),
      s(v("ki"), [n("vele"), n("meina")]),
      s(v("polini", tense: Tense::Complete), [n("vele"), n("leimina")])
    ]
    Parser.parse(text).should eq(expected)
  end

  pending "can parse the full text of Silika's Sleepsong" do
    text = <<-TEXT
    levi ti bome
    leimi ti mara
    romi ti nori
    mailomi gemi rita

    vele ki tuiri
    vele ki meina
    vele polini rita leimina

    belime rumi revi li seliti vi
    kena boli vi senai li
    lunata bera li vele be norima
    ro vele ki mine rila so ri

    voto ta mivila la rote
    musi ta fide ve kumei
    pelora ta luna beti
    de senui lumei

    mui leiri ta naro
    mui lura ta leimi vi lumite
    mui leiri ta naro
    mui lura ta suina vi lumite

    vele ki sevi
    vele ki luvi
    vele kola rita duna vi be tuto
    pena ta mani so meili
    TEXT
    expected = [] of Sentence
    Parser.parse(text).should eq(expected)
  end
end