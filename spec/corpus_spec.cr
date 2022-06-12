require "./spec_helper"

include Naidira

describe Parser do
  it "can parse the first verse of Silika's Sleepsong" do
    text = <<-TEXT
    levi ti bome
    leimi ti mara
    romi ti nori
    mailomi gemi rita
    TEXT
    expected = [
      s(v!("bome"), [nil, n("levi")]),
      s(v!("mara"), [nil, n("leimi")]),
      s(v!("nori"), [nil, n("romi")]),
      s(v("gemi", tense: Tense::Complete), [n("mailomi"), nil]),
    ]
    Parser.parse(text).should eq(expected)
  end

  it "can parse the second verse of Silika's Sleepsong" do
    text = <<-TEXT
    vele ki tuiri
    ne vele ki meina
    ne vele polini rita leimina
    TEXT
    expected = [
      s(v("ki"), [n("vele"), n("tuiri")]),
      s(v("ki"), [n("vele"), n("meina")]),
      s(v("polini", tense: Tense::Complete), [n("vele"), n("leimina")])
    ]
    Parser.parse(text).should eq(expected)
  end

  it "can parse the third verse of Silika's Sleepsong" do
    text = <<-TEXT
    ne belime rumi revi li seliti vi
    kena boli vi senai li
    lunata bera li vele be norima
    ro vele ki mine rila so ri
    TEXT
    expected = [
      s(v("revi", mood: Mood::Optative), [n("belime", "rumi"), n("seliti", attr: [:vi])]),
      s(v("senai", mood: Mood::Optative), [n("kena", "boli", attr: [:vi]), nil]),
      s(v("bera", m("be", n("norima", m: [m("ro", s(v("ki", m("so", n("ri")), mood: Mood::Optative),
        [n("vele"), n("rila")]))])), mood: Mood::Optative), [n("lunata"), n("vele")]),
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