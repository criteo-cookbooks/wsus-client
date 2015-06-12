require 'spec_helper'

describe 'wsus-client::default' do
  describe 'On windows platform' do
    let(:chef_run) do
      # Stubs wsus guard command
      cmd = '(New-Object -com "Microsoft.Update.Session").CreateUpdateSearcher().Search("IsInstalled=0").Updates.Count -eq 0'
      stub_command(cmd).and_return(true)
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2008R2').converge(described_recipe)
    end

    it 'includes configure and update recipes' do
      expect(chef_run).to include_recipe('wsus-client::configure')
      expect(chef_run).to include_recipe('wsus-client::update')
    end
  end

  describe 'On non-windows platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    it 'does nothing' do
      expect(chef_run.resource_collection).to be_empty
    end
  end
end
