wsus_client_update 'WSUS updates' do
  action             :install
  on_reboot_required proc { print 'Reboot required!'}
end
