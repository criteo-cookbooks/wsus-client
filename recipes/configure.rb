#
# Author:: Baptiste Courtois (<b.courtois@criteo.com>)
# Cookbook Name:: wsus-client
# Recipe:: configure
#
# Copyright:: Copyright (c) 2014 Criteo.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Microsoft documentation
#: registry configuration per http://technet.microsoft.com/en-us/library/dd939844.aspx
# Other documentation
#: http://smallvoid.com/article/winnt-automatic-updates-config.html
#
# WSUS is a windows only feature
return unless platform?('windows')

conf = node['wsus_client']

# Converts days symbols to AUOptions value
install_day = WsusClient::Helper.get_install_day conf['schedule_install_day']

# Converts symbols behavior to AUOptions value
au_options = WsusClient::Helper.get_behavior conf['automatic_update_behavior']

# Disables auto_update on au_options :disabled
no_auto_update = au_options == 1 ? 1 : 0

# Check other attributes values
WsusClient::Helper.check_limit(conf, 'detection_frequency', 22)
WsusClient::Helper.check_limit(conf, 'schedule_install_time', 23)
WsusClient::Helper.check_limit(conf, 'schedule_retry_wait', 60)
WsusClient::Helper.check_limit(conf, 'reboot_warning', 30)
WsusClient::Helper.check_limit(conf, 'reboot_prompt_timeout', 1440)

registry_key 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate' do
  values [
    # Allows signed non-Microsoft updates.
    { type:  :dword, name:   'AcceptTrustedPublisherCerts', data:  conf['enable_non_microsoft_updates'] ? 1 : 0 },
    # Disables access to Windows Update.
    { type:  :dword, name:    'DisableWindowsUpdateAccess', data: conf['disable_windows_update_access'] ? 1 : 0 },
    # Authorizes Users to approve or disapprove updates.
    { type:  :dword, name:              'ElevateNonAdmins', data: conf['allow_user_to_install_updates'] ? 1 : 0 },
    # Defines the current computer update group.
    { type: :string, name:                   'TargetGroup', data:                    conf['update_group'] } || '',
    # Allows client-side update group targeting.
    { type:  :dword, name:            'TargetGroupEnabled', data:                  conf['update_group'] ? 1 : 0 },
    # Defines the WSUS Server url.
    { type: :string, name:                      'WUServer', data:                           conf['wsus_server'] },
    { type: :string, name:                'WUStatusServer', data:                           conf['wsus_server'] },
  ]
  notifies :restart, 'service[wuauserv]', :immediately
  notifies :run, 'powershell_script[Force Windows update detection cycle]', :immediately
  recursive true
end

registry_key 'HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU' do
  values [
    # Defines Automatic Updates behavior.
    { type:  :dword, name:                     'AUOptions', data:                                    au_options },
    # Defines whether minor update should be automatically installed.
    { type:  :dword, name:       'AutoInstallMinorUpdates', data:    conf['auto_install_minor_updates'] ? 1 : 0 },
    # Defines times in hours between detection cycles (default frequency is 22 hours).
    { type:  :dword, name:            'DetectionFrequency', data:                   conf['detection_frequency'] },
    { type:  :dword, name:     'DetectionFrequencyEnabled', data:           conf['detection_frequency'] ? 1 : 0 },
    # Disables automatic reboot with logged-on users.
    { type:  :dword, name: 'NoAutoRebootWithLoggedOnUsers', data:   conf['no_reboot_with_logged_users'] ? 1 : 0 },
    # Disables automatic update detection, notification and installation.
    { type:  :dword, name:                  'NoAutoUpdate', data:                                no_auto_update },
    # Defines times in hours between detection cycles (default frequency is 22 hours).
    { type:  :dword, name:         'RebootRelaunchTimeout', data:                 conf['reboot_prompt_timeout'] },
    { type:  :dword, name:  'RebootRelaunchTimeoutEnabled', data:         conf['reboot_prompt_timeout'] ? 1 : 0 },
    # Defines scheduling and reboot settings.
    { type:  :dword, name:          'RebootWarningTimeout', data:                        conf['reboot_warning'] },
    { type:  :dword, name:   'RebootWarningTimeoutEnabled', data:                conf['reboot_warning'] ? 1 : 0 },
    { type:  :dword, name:            'RescheduleWaitTime', data:                   conf['schedule_retry_wait'] },
    { type:  :dword, name:     'RescheduleWaitTimeEnabled', data:           conf['schedule_retry_wait'] ? 1 : 0 },
    { type:  :dword, name:           'ScheduledInstallDay', data:                                   install_day },
    { type:  :dword, name:          'ScheduledInstallTime', data:                 conf['schedule_install_time'] },
    # Defines whether a custom WSUS server should be used instead of Microsoft Windows Update server.
    { type:  :dword, name:                   'UseWUServer', data:                   conf['wsus_server'] ? 1 : 0 },
  ]
  notifies :restart, 'service[wuauserv]', :immediately
  notifies :run, 'powershell_script[Force Windows update detection cycle]', :immediately
  recursive true
end

service 'wuauserv' do
  action :enable
end

# Force detection in case the client-side update group changed
powershell_script 'Force Windows update detection cycle' do
  code 'c:\windows\System32\wuauclt.exe /ResetAuthorization /DetectNow'
  action :nothing
end
