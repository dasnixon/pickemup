module Extensions
  extend ActiveSupport::Concern

  Enumerable.class_eval do
    def mode
      group_by do |e|
        e
      end.values.max_by(&:size).first
    end
  end
end
