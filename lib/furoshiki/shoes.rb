module Furoshiki
  module Shoes
    def self.new(backend, wrapper, config)
      class_name = class_name_for(backend, wrapper)
      self.const_get(class_name).new(config)
    end

    def self.class_name_for(backend, wrapper)
      [backend, wrapper].map { |name| name.to_s.capitalize }.join
    end
  end
end
