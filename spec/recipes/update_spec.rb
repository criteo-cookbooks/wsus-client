require 'spec_helper'

describe 'wsus-client::update' do
  describe 'On windows platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2008R2').converge(described_recipe)
    end

    RESOURCE_NAME = 'wsus_update_script'
    GUARD_CMD = '(New-Object -com "Microsoft.Update.Session").CreateUpdateSearcher().Search("IsInstalled=0").Updates.Count -eq 0'

    it 'does not run a complexe powershellscript when no update found' do
      stub_command(GUARD_CMD).and_return(true)

      expect(chef_run).to_not run_powershell_script(RESOURCE_NAME)
    end

    it 'runs a complexe powershellscript when update(s) found' do
      stub_command(GUARD_CMD).and_return(false)

      expect(chef_run).to run_powershell_script(RESOURCE_NAME)
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
