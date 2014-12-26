module Furoshiki
  class WarblerExtensions
    def initialize(config)
      @config = config
    end

    # Override to customize config
    def customize(warbler_config)
      warbler_config
    end
  end
end
