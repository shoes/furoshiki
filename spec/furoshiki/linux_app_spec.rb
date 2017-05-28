require 'spec_helper'
require 'pathname'
require 'furoshiki/linux_app'

include PackageHelpers

describe Furoshiki::LinuxApp do
  include_context 'generic furoshiki app'

  subject { Furoshiki::LinuxApp.new config }

  let(:config) { Furoshiki::Configuration.new @custom_config }
  let(:launcher) { @output_file.join('Sugar Clouds') }
  let(:jar) { @output_file.join('app.jar') }

  describe "default" do
    it "caches current version of template" do
      expect(subject.template_path).to eq(cache_dir.join('linux-app-template-0.0.1.zip'))
    end

    its(:remote_template_url) { should match(%r{https://github.com/.*/linux-app-templates/releases/download/.*/linux-app-template.*.zip}) }
  end

  describe "when creating an app" do
    before do
      create_package(Furoshiki::LinuxApp, "Sugar Clouds-linux")
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

    it "injects jar" do
      expect(jar).to exist
    end
  end
end
