require 'spec_helper'
require 'furoshiki/windows_app'

describe Furoshiki::WindowsApp do
  include_context 'generic furoshiki app'

  let(:packaging_class) { Furoshiki::WindowsApp }

  let(:archive)  { ZipReader.new(subject.archive_path) }
  let(:app_dir)  { "Sugar Clouds-windows" }

  let(:launcher) { "#{app_dir}/Sugar Clouds.bat" }
  let(:jar)      { "#{app_dir}/app.jar" }

  describe "default" do
    it "caches current version of template" do
      expect(subject.template_path).to eq(cache_dir.join('windows-app-template-0.0.1.zip'))
    end

    its(:remote_template_url) { should match(%r{https://github.com/.*/windows-app-templates/releases/download/.*/windows-app-template.*.zip}) }
  end

  describe "when creating an app" do
    its(:template_path) { should exist }

    it "creates the archive" do
      expect(subject.archive_path).to exist
    end

    it "includes launcher" do
      expect(archive.include?(launcher)).to be_truthy
    end

    it "injects jar" do
      expect(archive.include?(jar)).to be_truthy
    end
  end
end
