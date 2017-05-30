require 'spec_helper'
require 'pathname'
require 'plist'
require 'furoshiki/mac_app'

describe Furoshiki::MacApp do
  include PackageHelpers

  include_context 'generic furoshiki app'

  subject { Furoshiki::MacApp.new config }
  let(:config) { Furoshiki::Configuration.new @custom_config }
  let(:launcher) { @output_file.join('Contents/MacOS/app') }
  let(:icon)  { @output_file.join('Contents/Resources/boots.icns') }
  let(:jar) { @output_file.join('Contents', 'Java', 'app.jar') }

  describe "default" do
    it "caches current version of template" do
      expect(subject.template_path).to eq(cache_dir.join('mac-app-template-0.0.3.zip'))
    end

    its(:remote_template_url) { should match(%r{https://github.com/.*/mac-app-templates/releases/download/.*/mac-app-template.*.zip}) }
  end

  describe "when creating an app" do
    before do
      create_package(Furoshiki::MacApp, 'Sugar Clouds.app')
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
      before do
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
end
