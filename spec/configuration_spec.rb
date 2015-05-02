require 'spec_helper'
require 'furoshiki/configuration'

describe Furoshiki::Configuration do
  subject(:config) { Furoshiki::Configuration.new(raw_config) }

  let(:raw_config) { { warbler_extensions: OtherCustomization,
                       ignore: "pkg" } }

  class OtherCustomization < Furoshiki::WarblerExtensions
    def customize(config)
      # Actual behavior with shoes-package overrides the application name, so
      # for testing purposes reset it here too.
      config.pathmaps.application = ["shoes-app/%p"]
    end
  end

  it "is valid by default" do
    expect(config).to be_valid
  end

  it "uses correct application path for exclusions" do
    raw_config[:warbler_extensions] = OtherCustomization
    raw_config[:ignore] = "pkg"

    expect(config.to_warbler_config.excludes).to include("shoes-app/pkg")
  end
end
