require 'spec_helper'

describe 'wsus-client::update' do
  describe 'On windows platform' do
    def chef_run(download_only = false)
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2016') do |node|
        node.set['wsus_client']['update']['action'] = download_only ? [:download] : [:download, :install]
      end.converge(described_recipe)
    end

    RESOURCE_NAME = 'WSUS updates'

    it 'includes configure recipe' do
      expect(chef_run).to include_recipe('wsus-client::configure')
    end

    it 'downloads only updates when wsus_client.download_only = true' do
      run = chef_run(true)
      expect(run).to download_wsus_client_update(RESOURCE_NAME)
      expect(run).not_to install_wsus_client_update(RESOURCE_NAME)
    end

    it 'downloads and installs updates when wsus_client.download_only = false' do
      run = chef_run(false)
      expect(run).to download_wsus_client_update(RESOURCE_NAME)
      expect(run).to install_wsus_client_update(RESOURCE_NAME)
    end
  end

  describe 'On non-windows platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.4.1708').converge(described_recipe)
    end

    it 'does nothing' do
      expect(chef_run.resource_collection).to be_empty
    end
  end
end
