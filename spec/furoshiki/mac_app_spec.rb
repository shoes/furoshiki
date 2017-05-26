require 'spec_helper'
require 'pathname'
require 'furoshiki/mac_app'

include PackageHelpers

describe Furoshiki::MacApp do
  include_context 'generic furoshiki app'

  let(:config) { Furoshiki::Configuration.new @custom_config }
  subject { Furoshiki::MacApp.new config }

  let(:launcher) { @output_file.join('Contents/MacOS/app') }
  let(:icon)  { @output_file.join('Contents/Resources/boots.icns') }
  let(:jar) { @output_file.join('Contents', 'Java', 'app.jar') }

  # $FUROSHIKI_HOME is set in spec_helper.rb for testing purposes,
  # but should default to $HOME
  describe "when not setting $FUROSHIKI_HOME" do
    before do
      @old_furoshiki_home = ENV['FUROSHIKI_HOME']
      ENV['FUROSHIKI_HOME'] = nil
    end

    its(:cache_dir) { should eq(Pathname.new(Dir.home).join('.furoshiki', 'cache')) }

    after do
      ENV['FUROSHIKI_HOME'] = @old_furoshiki_home
    end
  end

  describe "default" do
    let(:cache_dir) { Pathname.new(FUROSHIKI_SPEC_DIR).join('.furoshiki', 'cache') }
    its(:cache_dir) { should eq(cache_dir) }

    it "sets package dir to {pwd}/pkg" do
      Dir.chdir @app_dir do
        expect(subject.default_package_dir).to eq(@app_dir.join 'pkg')
      end
    end

    it "caches current version of template" do
      expect(subject.template_path).to eq(cache_dir.join('mac-app-template-0.0.3.zip'))
    end

    its(:remote_template_url) { should match(%r{https://github.com/.*/mac-app-templates/releases/download/.*/mac-app-template.*.zip}) }
  end

  describe "when creating an app" do
    before :all do
      @output_dir.rmtree if @output_dir.exist?
      @output_dir.mkpath

      app_name = 'Sugar Clouds.app'
      @output_file = @output_dir.join app_name

      # Config picks up Dir.pwd
      Dir.chdir @app_dir do
        config = Furoshiki::Configuration.new(@custom_config)
        @subject = Furoshiki::MacApp.new(config)
        @subject.package
      end
    end

    subject { @subject }

    its(:template_path) { should exist }

    it "creates the app directory" do
      expect(@output_file).to exist
    end

    it "includes launcher" do
      expect(launcher).to exist
    end

    # Windows can't test this
    platform_is_not :windows do
      it "makes launcher executable" do
        expect(launcher).to be_executable
      end
    end

    it "deletes generic icon" do
      expect(icon.parent.join('GenericApp.icns')).not_to exist
    end

    it "injects icon" do
      expect(icon).to exist
    end

    it "injects jar" do
      expect(jar).to exist
    end

    it "removes any extraneous jars" do
      jar_dir_contents = @output_file.join("Contents/Java").children
      expect(jar_dir_contents.reject { |f| f == jar }).to be_empty
    end

    describe "Info.plist" do
      require 'plist'
      before :all do
        @plist = Plist.parse_xml(@output_file.join('Contents/Info.plist'))
      end

      it "sets identifier" do
        expect(@plist['CFBundleIdentifier']).to eq('com.hackety.shoes.sweet-nebulae')
      end

      it "sets display name" do
        expect(@plist['CFBundleDisplayName']).to eq('Sugar Clouds')
      end

      it "sets bundle name" do
        expect(@plist['CFBundleName']).to eq('Sugar Clouds')
      end

      it "sets icon" do
        expect(@plist['CFBundleIconFile']).to eq('boots.icns')
      end

      it "sets version" do
        expect(@plist['CFBundleVersion']).to eq('0.0.1')
      end
    end
  end

  describe "with an invalid configuration" do
    before do
      allow(config).to receive(:valid?) { false }
    end

    it "fails to initialize" do
      expect { subject }.to raise_error(Furoshiki::ConfigurationError)
    end
  end
end