require 'spec_helper'
require 'pathname'
require 'furoshiki/windows_app'

describe Furoshiki::WindowsApp do
  include PackageHelpers

  include_context 'generic furoshiki app'

  subject { Furoshiki::WindowsApp.new config }

  let(:config) { Furoshiki::Configuration.new @custom_config }
  let(:launcher) { @output_file.join('Sugar Clouds.bat') }
  let(:jar) { @output_file.join('app.jar') }

  describe "default" do
    it "caches current version of template" do
      expect(subject.template_path).to eq(cache_dir.join('windows-app-template-0.0.1.zip'))
    end

    its(:remote_template_url) { should match(%r{https://github.com/.*/windows-app-templates/releases/download/.*/windows-app-template.*.zip}) }
  end

  describe "when creating an app" do
    before do
      create_package(Furoshiki::WindowsApp, "Sugar Clouds-windows")
    end

    subject { @subject }

    its(:template_path) { should exist }

    it "creates the app directory" do
      expect(@output_file).to exist
    end

    it "includes launcher" do
      expect(launcher).to exist
    end

    it "injects jar" do
      expect(jar).to exist
    end
  end
end
