class String
  SYMBOLS = /#{Moji.symbol}|#{Moji.line}|[ 　−-]/
  def remove_symbols
    self.split("").select {|s| not s =~ SYMBOLS}.join("")
  end
end
