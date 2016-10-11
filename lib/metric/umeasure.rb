# -*- coding: utf-8 -*-
module Metric
  #= Umeasure
  # Duplicate iUnits are considered as irrelevant
  class Umeasure
    #[l]
    # patience parameter
    #[n]
    # normalization parameter (default: 1.0)
    def initialize(l, n=1.0)
      @l = l
      @n = n
    end

    #Uを計算
    #[systemlist]
    # a list of Element
    def evaluate(systemlist)
      cummurative = 0.0
      pos = 0.0
      read_iunits = Set.new
      systemlist.each do |elem|
        # pos = the sum of len
        pos += elem.len
        eid = elem.eid
        unless read_iunits.include?(eid)
          # ignore iUnits that have already been read
          cummurative += elem.importance * decay(pos)
          read_iunits << eid
        end
      end
      result = cummurative / @n
      return result
    end

    private

      # decay function
      def decay(pos)
        return [0.0, 1.0 - pos / @l].max
      end

  end
end


