module Furoshiki
  module Shoes
    def self.new(backend, wrapper, config)
      backend_class_name = backend.to_s.capitalize
      wrapper_class_name = wrapper.to_s.capitalize
      klass = self.const_get("#{backend_class_name}#{wrapper_class_name}")
      klass.new config
    rescue LoadError => e
      raise LoadError, "Couldn't load backend '#{backend}'. Error: #{e.message}\n#{e.backtrace.join("\n")}"
    end
  end
end
