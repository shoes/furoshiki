require 'spec_helper'
require_relative 'spec_helper'
require 'pathname'
require 'furoshiki/shoes/swt_jar'

include PackageHelpers

describe Furoshiki::Shoes::SwtJar do
  include_context 'config'
  include_context 'package'

  context "when creating a .jar" do
    before :all do
      @output_dir.rmtree if @output_dir.exist?
      @output_dir.mkpath
      config = Furoshiki::Shoes::Configuration.load(@config_filename)
      @subject = Furoshiki::Shoes::SwtJar.new(config)
      Dir.chdir @app_dir do
        @jar_path = @subject.package(@output_dir)
      end
    end

    let(:jar_name) { 'sweet-nebulae.jar' }
    let(:output_file) { Pathname.new(@output_dir.join jar_name) }
    subject { @subject }

    it "creates a .jar" do
      output_file.should exist
    end

    it "returns path to .jar" do
      @jar_path.should eq(output_file.to_s)
    end

    it "creates .jar smaller than 50MB" do
      File.size(output_file).should be < 50 * 1024 * 1024
    end

    it "excludes directories recursively" do
      jar = Zip::ZipFile.new(output_file)
      jar.entries.should_not include("dir_to_ignore/file_to_ignore")
    end

    its(:default_dir) { should eq(@output_dir) }
    its(:filename) { should eq(jar_name) }
  end

  describe "with an invalid configuration" do
    let(:config) { Furoshiki::Shoes::Configuration.new }
    subject { Furoshiki::Shoes::SwtJar.new(config) }

    it "fails to initialize" do
      lambda { subject }.should raise_error(Furoshiki::ConfigurationError)
    end
  end
end
