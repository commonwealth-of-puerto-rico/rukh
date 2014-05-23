class HexString < String
  def initialize(string)
    #/[[:xdigit:]]+/ not needing because it's one char at a time
    super(string.each_char.select{|x| x.match(/[0-9]|[a-f]/i)}.join(''))
  end
end
