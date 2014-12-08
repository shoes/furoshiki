require 'furoshiki/shoes/configuration'

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
        # Actually, it would be better to dump the NoGemspec trait, but since
        # we can't do that, we can at least make sure that this trait gets
        # processed later by declaring that it requires NoGemspec.
        [Traits::Jar, Traits::NoGemspec].include? trait
      end

      def update_archive(jar)
        # Not sure why Warbler doesn't do this automatically
        jar.files.delete_if { |k, v| @config.excludes.include? k }
      end
    end
  end
end
