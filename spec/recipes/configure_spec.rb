require 'spec_helper'

describe 'wsus-client::configure' do
  describe 'On windows platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2008R2').converge(described_recipe)
    end

    WINDOWS_UPDATE_KEY = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate'
    WINDOWS_AUTO_UPDATE_KEY = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU'
    WUAUSERV_SERVICE_NAME = 'wuauserv'
    DETECTION_EXECUTE_NAME = 'Force Windows update detection cycle'

    it 'configures windows update and restart wuauserv' do
      key = WINDOWS_UPDATE_KEY
      expect(chef_run).to create_registry_key(key).with(recursive: true)

      resource = chef_run.registry_key key
      notify_name = "service[#{WUAUSERV_SERVICE_NAME}]"
      expect(resource).to notify(notify_name).to(:restart).immediately
    end

    it 'configures windows Auto Update and restart wuauserv' do
      key = WINDOWS_AUTO_UPDATE_KEY
      expect(chef_run).to create_registry_key(key).with(recursive: true)

      resource = chef_run.registry_key key
      notify_name = "service[#{WUAUSERV_SERVICE_NAME}]"
      expect(resource).to notify(notify_name).to(:restart).immediately
    end

    it 'starts and enable wuauserv service and force update cycle detection' do
      expect(chef_run).to start_service(WUAUSERV_SERVICE_NAME)
      expect(chef_run).to enable_service(WUAUSERV_SERVICE_NAME)

      resource = chef_run.service WUAUSERV_SERVICE_NAME
      notify_name = "powershell_script[#{DETECTION_EXECUTE_NAME}]"
      expect(resource).to notify(notify_name).to(:run).immediately
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
