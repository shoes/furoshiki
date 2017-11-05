require 'spec_helper'
require 'furoshiki/mac_app'

describe Furoshiki::MacApp do
  include_context 'generic furoshiki app'

  let(:packaging_class) { Furoshiki::MacApp }

  let(:archive)      { TarGzReader.new(subject.archive_path) }
  let(:app_dir)      { "Sugar Clouds.app" }

  let(:launcher)     { "#{app_dir}/Contents/MacOS/app" }
  let(:jar)          { "#{app_dir}/Contents/Java/app.jar" }
  let(:icon)         { "#{app_dir}/Contents/Resources/boots.icns" }
  let(:generic_icon) { "#{app_dir}/Contents/Resources/GenericApp.icns" }

  describe "default" do
    it "caches current version of template" do
      expect(subject.template_path).to eq(cache_dir.join('mac-app-template-0.0.4.zip'))
    end

    its(:remote_template_url) { should match(%r{https://github.com/.*/mac-app-templates/releases/download/.*/mac-app-template.*.zip}) }
  end

  describe "when creating an app" do
    its(:template_path) { should exist }

    it "creates the archive" do
      expect(subject.archive_path).to exist
    end

    it "includes launcher" do
      expect(archive.include?(launcher)).to be_truthy
    end

    it "makes launcher executable" do
      expect(archive.executable?(launcher)).to be_truthy
    end

    it "deletes generic icon" do
      expect(archive.include?(generic_icon)).to be_falsey
    end

    it "injects icon" do
      expect(archive.include?(icon)).to be_truthy
    end

    it "injects jar" do
      expect(archive.include?(jar)).to be_truthy
    end

    it "removes any extraneous jars" do
      contents = archive.match("#{app_dir}/Contents/Java/*")
      expect(contents).to eq([jar])
    end

    describe "Info.plist" do
      let(:plist) { Plist.parse_xml(archive.contents("#{app_dir}/Contents/Info.plist")) }

      it "sets identifier" do
        expect(plist['CFBundleIdentifier']).to eq('com.hackety.shoes.sweet-nebulae')
      end

      it "sets display name" do
        expect(plist['CFBundleDisplayName']).to eq('Sugar Clouds')
      end

      it "sets bundle name" do
        expect(plist['CFBundleName']).to eq('Sugar Clouds')
      end

      it "sets icon" do
        expect(plist['CFBundleIconFile']).to eq('boots.icns')
      end

      it "sets version" do
        expect(plist['CFBundleVersion']).to eq('0.0.1')
      end
    end
  end
end
