require 'spec_helper'
require 'furoshiki/configuration'

describe Furoshiki::Configuration do
  context "defaults" do
    let(:config) { Furoshiki::Configuration.new }

    it "is valid" do
      expect(config).to be_valid
    end
  end
end
