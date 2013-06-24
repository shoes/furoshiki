require 'spec_helper'
require_relative 'spec_helper'
require 'pathname'
require 'furoshiki/shoes/swt_app'

include PackageHelpers

describe Furoshiki::Shoes::SwtApp do
  include_context 'config'
  include_context 'package'

  let(:app_name) { 'Sugar Clouds.app' }
  let(:output_file) { output_dir.join app_name }
  let(:config) { Furoshiki::Shoes::Configuration.load config_filename}
  let(:launcher) { output_file.join('Contents/MacOS/JavaAppLauncher') }
  let(:icon)  { output_file.join('Contents/Resources/boots.icns') }
  let(:jar) { output_file.join('Contents/Java/sweet-nebulae.jar') }
  subject { Furoshiki::Shoes::SwtApp.new config }

  # $FUROSHIKI_HOME is set in spec_helper.rb for testing purposes,
  # but should default to $HOME
  context "when not setting $FUROSHIKI_HOME" do
    before do
      @old_furoshiki_home = ENV['FUROSHIKI_HOME']
      ENV['FUROSHIKI_HOME'] = nil
    end

    its(:cache_dir) { should eq(Pathname.new(Dir.home).join('.furoshiki', 'cache')) }

    after do
      ENV['FUROSHIKI_HOME'] = @old_furoshiki_home
    end
  end

  context "default" do
    let(:cache_dir) { Pathname.new(SHOESSPEC_ROOT).join('.furoshiki', 'cache') }
    its(:cache_dir) { should eq(cache_dir) }

    it "sets package dir to {pwd}/pkg" do
      Dir.chdir app_dir do
        subject.default_package_dir.should eq(app_dir.join 'pkg')
      end
    end

    its(:template_path) { should eq(cache_dir.join('shoes-app-template.zip')) }
    its(:remote_template_url) { should eq(Furoshiki::Shoes::SwtApp::REMOTE_TEMPLATE_URL) }
  end

  context "when creating a .app" do
    before :all do
      output_dir.rmtree if output_dir.exist?
      output_dir.mkpath
      Dir.chdir app_dir do
        subject.package
      end
    end

    its(:template_path) { should exist }

    it "creates a .app" do
      output_file.should exist
    end

    it "includes launcher" do
      launcher.should exist
    end

    # Windows can't test this
    platform_is_not :windows do
      it "makes launcher executable" do
        launcher.should be_executable
      end
    end

    it "deletes generic icon" do
      icon.parent.join('GenericApp.icns').should_not exist 
    end

    it "injects icon" do
      icon.should exist
    end

    it "injects jar" do
      jar.should exist
    end

    it "removes any extraneous jars" do
      jar_dir_contents = output_file.join("Contents/Java").children
      jar_dir_contents.reject {|f| f == jar }.should be_empty
    end

    describe "Info.plist" do
      require 'plist'
      before :all do
        @plist = Plist.parse_xml(output_file.join 'Contents/Info.plist')
      end

      it "sets identifier" do
        @plist['CFBundleIdentifier'].should eq('com.hackety.shoes.sweet-nebulae')
      end

      it "sets display name" do
        @plist['CFBundleDisplayName'].should eq('Sugar Clouds')
      end

      it "sets bundle name" do
        @plist['CFBundleName'].should eq('Sugar Clouds')
      end

      it "sets icon" do
        @plist['CFBundleIconFile'].should eq('boots.icns')
      end

      it "sets version" do
        @plist['CFBundleVersion'].should eq('0.0.1')
      end
    end
  end

  describe "with an invalid configuration" do
    let(:config) { Furoshiki::Shoes::Configuration.new }

    it "fails to initialize" do
      lambda { subject }.should raise_error(Furoshiki::ConfigurationError)
    end
  end
end
