require 'spec_helper'

describe 'wsus-client::configure' do
  describe 'On windows platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2016').converge(described_recipe)
    end

    WINDOWS_UPDATE_KEY = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate'.freeze
    WINDOWS_AUTO_UPDATE_KEY = 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU'.freeze
    WUAUSERV_SERVICE_NAME = 'wuauserv'.freeze
    DETECTION_EXECUTE_NAME = 'Force Windows update detection cycle'.freeze

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

    it 'notifies the update detection script' do
      [WINDOWS_UPDATE_KEY, WINDOWS_AUTO_UPDATE_KEY].each do |name|
        resource = chef_run.registry_key name
        notify_name = "powershell_script[#{DETECTION_EXECUTE_NAME}]"
        expect(resource).to notify(notify_name).to(:run).immediately
      end
    end

    it 'enable wuauserv service' do
      expect(chef_run).to enable_service(WUAUSERV_SERVICE_NAME)
    end
  end

  describe 'On non-windows platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7').converge(described_recipe)
    end

    it 'does nothing' do
      expect(chef_run.resource_collection).to be_empty
    end
  end
end
