include ZipHelpers

shared_context 'package' do
  before :all do
    @app_dir = spec_dir.join 'shoes/test_app'
    @output_dir = @app_dir.join 'pkg'
  end
end

shared_context 'zip' do
  include_context 'package'
  let(:output_file) { @output_dir.join 'zip_directory_spec.zip' }
  let(:zip) { Zip::ZipFile.open output_file }

  before :all do
    @output_dir.mkpath
    @output_file = @output_dir.join 'zip_directory_spec.zip'
  end

  after :all do
    FileUtils.rm_rf @output_dir
  end
end
