require 'spec_helper'
require_relative 'spec_helper'
require 'pathname'
require 'furoshiki'

describe Furoshiki::Jar do
  include_context 'generic furoshiki app'

  let(:packaging_class) { Furoshiki::Jar }

  let(:archive) { ZipReader.new(output_file) }

  describe "when creating a .jar" do
    let(:jar_name)    { 'sweet-nebulae.jar' }
    let(:output_file) { Pathname.new(subject.default_dir.join jar_name) }

    its(:filename) { should eq(jar_name) }

    it "creates a .jar" do
      expect(output_file).to exist
    end

    it "creates .jar smaller than 50MB" do
      expect(File.size(output_file)).to be < 50 * 1024 * 1024
    end

    describe "inspecting contents" do
      it "includes a specified gem" do
        expect(archive.include?("gems/rubyzip*")).to be_truthy
      end

      it "does not include a non-specified gem" do
        expect(archive.include?("gems/warbler*")).to be_falsey
      end
    end
  end

  describe "with an invalid configuration" do
    let(:invalid_config) { Furoshiki::Configuration.new }
    subject { Furoshiki::Jar.new(invalid_config) }

    before do
      allow(invalid_config).to receive(:valid?) { false }
    end

    it "fails to initialize" do
      expect { subject }.to raise_error(Furoshiki::ConfigurationError)
    end
  end
end
