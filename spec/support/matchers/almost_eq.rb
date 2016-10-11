RSpec::Matchers.define :almost_eq do |expected, places| 

  match do |actual|
    expect((actual * 10 ** places).round).to eq (expected * 10 ** places).round
  end

  failure_message do |actual|
    "#{actual} expected to approximately equal #{expected},
      rounding to the given number of decimal places #{places}"
  end

  failure_message_when_negated do |actual|
    "#{actual} expected not to approximately equal #{expected}, 
      rounding to the given number of decimal places #{places}"
  end

end
