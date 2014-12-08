require 'spec_helper'
require_relative 'spec_helper'
require 'pathname'
require 'furoshiki/jar'
require 'furoshiki/shoes/configuration'

include PackageHelpers

describe Furoshiki::Jar do
  include_context 'generic furoshiki config'
  include_context 'generic furoshiki project'

  context "when creating a .jar" do
    before :all do
      @output_dir.rmtree if @output_dir.exist?
      @output_dir.mkpath
      # config = Furoshiki::Shoes::Configuration.load(@config_filename)

      # Config picks up Dir.pwd
      Dir.chdir @app_dir do
        config = Furoshiki::Configuration.new(@custom_config)
        @subject = Furoshiki::Jar.new(config)
        @jar_path = @subject.package(@output_dir)
      end
    end

    let(:jar_name) { 'rubyapp.jar' }
    let(:output_file) { Pathname.new(@output_dir.join jar_name) }
    subject { @subject }

    it "creates a .jar" do
      expect(output_file).to exist
    end

    it "returns path to .jar" do
      expect(@jar_path).to eq(output_file.to_s)
    end

    it "creates .jar smaller than 50MB" do
      expect(File.size(output_file)).to be < 50 * 1024 * 1024
    end

    context "inspecting contents" do
      let (:jar) { Zip::File.new(output_file) }

      it "includes a specified gem" do
        expect(jar.glob "gems/rubyzip*").to_not be_empty
      end

      it "does not include a non-specified gem" do
        expect(jar.glob "gems/warbler*").to be_empty
      end
    end

    its(:default_dir) { should eq(@output_dir) }
    its(:filename) { should eq(jar_name) }
  end

  describe "with an invalid configuration" do
    let(:config) { Furoshiki::Shoes::Configuration.create}
    subject { Furoshiki::Jar.new(config) }

    it "fails to initialize" do
      expect { subject }.to raise_error(Furoshiki::ConfigurationError)
    end
  end
end
