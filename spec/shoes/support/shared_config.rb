require 'yaml'
require 'pathname'

shared_context 'config' do
  before :all do
    @config_filename = Pathname.new(__FILE__).join('../../test_app/app.yaml').cleanpath
  end
end
