module Warbler
  module Traits
    # Hack to stop bundler injecting itself
    class Bundler
      def self.detect?
        false
      end
    end

    class Furoshiki
      include Trait
      include PathmapHelper

      def self.detect?
        true
      end

      def self.requires?(trait)
        [Traits::Jar].include? trait
      end

      def update_archive(jar)
        # Not sure why Warbler doesn't do this automatically
        jar.files.delete_if { |k, v| @config.excludes.include? k }
      end
    end
  end
end
