require 'spec_helper'
require 'rails_helper'

describe 'String' do

  describe 'removes symbols' do
    it { expect("I'm a student!?".remove_symbols).to eq("Imastudent") }
    it { expect("\"'M-()a%&$ny sy[]@*.,_mbols ".remove_symbols).to eq("Manysymbols") }
    it { expect("「日本語」　【の】　『テスト』！？".remove_symbols).to eq("日本語のテスト") }
    it { expect("日本語の文字数Test".remove_symbols.size).to eq(11) }
  end

end
