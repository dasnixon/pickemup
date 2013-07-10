module StackexchangeHelper
  extend ActiveSupport::Concern

  Array.class_eval do
    def collect_reputation
      self.collect { |rep| rep.reputation_change }.inject(:+) + 1
    end
  end
end
