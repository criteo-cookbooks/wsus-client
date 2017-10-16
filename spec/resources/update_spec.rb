# contains useful mock methods!
require 'spec_helper'

describe 'wsus_client_update' do
  # Mock some updates
  let(:downloadable_update) { double('downloadable_update', IsDownloaded: false) }
  let(:downloaded_update) { double('downloaded_update', IsDownloaded: true, EulaAccepted: false, Title: nil, AcceptEula: nil) }
  let(:downloaded_update_with_eula) { double('downloaded_update', IsDownloaded: true, EulaAccepted: true, Title: nil, AcceptEula: nil) }
  # Mock OLE objects
  let(:session) { double('update_session', CreateUpdateDownloader: downloader, CreateUpdateInstaller: installer, CreateUpdateSearcher: searcher) }
  let(:downloader) { double('update_downloader') }
  let(:installer) { double('update_installer', ForceQuiet: true) }
  let(:searcher) { double('update_installer', ForceQuiet: true) }
  # Mock some OLE results
  let(:success) { double('success', HResult: 0, ResultCode: 2) }
  let(:failure) { double('failure', HResult: 1, ResultCode: 42) }

  before do
    # Mocks WIN32OLE object creation
    stub_const('::WIN32OLE', ::Class.new) unless defined? ::WIN32OLE
    allow(::WIN32OLE).to receive(:new).and_call_original
    allow(::WIN32OLE).to receive(:new).with('Microsoft.Update.Session').and_return session
  end

  describe 'action download' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2016', step_into: ['wsus_client_update'])
                          .converge('wsus-client-test::download_update')
    end

    it 'does nothing if no available update' do
      mock_search searcher, []

      expect { chef_run }.to_not raise_error
      expect(chef_run.wsus_client_update('WSUS updates').updated?).to be_falsey
    end

    it 'fails when an error occured with the downloader' do
      mock_search searcher, [downloadable_update]
      mock_job downloader, :download, failure

      msg = /Operation failed. \(Error code #{failure.HResult} - Result code #{failure.ResultCode}\)/
      expect { chef_run }.to raise_error(msg)
    end

    it 'downloads only non-downloaded updates' do
      mock_search searcher, [downloadable_update, downloaded_update, downloaded_update_with_eula]
      collection = mock_job downloader, :download, success

      expect { chef_run }.to_not raise_error
      expect(collection.updates.count).to be 1
      expect(collection.updates).to include downloadable_update
      expect(collection.updates).to_not include downloaded_update
      expect(collection.updates).to_not include downloaded_update_with_eula
      expect(chef_run.wsus_client_update('WSUS updates').updated?).to be_truthy
    end
  end

  describe 'action install' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'windows', version: '2016', step_into: ['wsus_client_update'])
                          .converge('wsus-client-test::install_update')
    end

    it 'does nothing if no available update' do
      mock_search searcher, []

      expect { chef_run }.to_not raise_error
      expect(chef_run.wsus_client_update('WSUS updates').updated?).to be_falsey
    end

    it 'fails when an error occured with the installer' do
      mock_search searcher, [downloaded_update]
      mock_job installer, :install, failure

      msg = /Operation failed. \(Error code #{failure.HResult} - Result code #{failure.ResultCode}\)/
      expect { chef_run }.to raise_error(msg)
    end

    it 'installs only downloaded updates' do
      mock_search searcher, [downloadable_update, downloaded_update, downloaded_update_with_eula]
      collection = mock_job installer, :install, success

      expect { chef_run }.to_not raise_error
      expect(collection.updates.count).to be 2
      expect(collection.updates).to_not include downloadable_update
      expect(collection.updates).to include downloaded_update
      expect(collection.updates).to include downloaded_update_with_eula
      expect(chef_run.wsus_client_update('WSUS updates').updated?).to be_truthy
    end
  end
end
