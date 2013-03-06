require_relative 'spec_helper'
require_relative 'support/shared_zip'
require 'fileutils'
require 'furoshiki/zip'

describe Furoshiki::Zip::DirectoryContents do
  subject { Furoshiki::Zip::DirectoryContents.new input_dir, output_file }

  context "output file" do
    include_context 'zip'

    it "exists" do
      output_file.should exist
    end

    it "does not include input directory without parents" do
      zip.entries.map(&:name).should_not include(add_trailing_slash input_dir.basename)
    end

    relative_input_paths(input_dir).each do |path|
      it "includes all children of input directory" do
        zip.entries.map(&:name).should include(path)
      end
    end
  end
end
