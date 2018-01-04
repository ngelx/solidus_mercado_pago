# rubocop:disable Style/RegexpLiteral
# rubocop:disable Rspec/FilePath

require 'spec_helper'
require 'generator_spec'
require 'generators/solidus_mercado_pago/install/install_generator'

describe SolidusMercadoPago::Generators::InstallGenerator, type: :generator do
  destination File.expand_path('../../../../tmp', __FILE__)

  let(:dest) do
    File.expand_path('../../../../tmp', __FILE__)
  end

  before do
    prepare_destination
    FileUtils.mkdir_p "#{dest}/vendor/assets/javascripts/spree/frontend"
    FileUtils.mkdir_p "#{dest}/vendor/assets/javascripts/spree/backend"
    FileUtils.touch "#{dest}/vendor/assets/javascripts/spree/frontend/all.js"
    FileUtils.touch "#{dest}/vendor/assets/javascripts/spree/backend/all.js"
    run_generator %w[--auto_skip_migrations]
  end

  it 'creates a test initializer' do
    assert_file "#{dest}/vendor/assets/javascripts/spree/frontend/all.js", /^\/\/= require spree\/frontend\/solidus_mercado_pago/
  end

  it { assert_file "#{dest}/vendor/assets/javascripts/spree/backend/all.js", /^\/\/= require spree\/backend\/solidus_mercado_pago/ }

  after do
    FileUtils.rm_rf destination_root
  end
end
