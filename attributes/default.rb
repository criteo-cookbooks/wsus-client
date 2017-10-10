#
# Author:: Baptiste Courtois (<b.courtois@criteo.com>)
# Cookbook Name:: wsus-client
# Attribute:: default
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
#
# WSUS is a windows feature
return unless platform?('windows')

# Defines whether a custom WSUS server should be used instead of Microsoft Windows Update server.
default['wsus_client']['wsus_server']                              = nil

# Defines the current computer update group.
# => Truthy value also enable client-side update group targeting.
default['wsus_client']['update_group']                             = nil

# Disables access to Windows Update (or your WSUS server).
default['wsus_client']['disable_windows_update_access']            = false
# Allows signed non-Microsoft updates.
default['wsus_client']['enable_non_microsoft_updates']             = true
# Authorizes Users to approve or disapprove updates.
default['wsus_client']['allow_user_to_install_updates']            = false
# Defines whether minor update should be automatically installed.
default['wsus_client']['auto_install_minor_updates']               = false
# Disables automatic reboot with logged-on users.
default['wsus_client']['no_reboot_with_logged_users']              = true

# Defines auto update behavior.
# => :disabled  = Disables automatic updates
# => :detect    = Only notify users of new updates
# => :download  = Download updates, but lets users install them
# => :install   = Download and install updates
# => :manual    = Lets the users configure the behavior
default['wsus_client']['automatic_update_behavior']                = :disabled

# Defines times in hours between detection cycles.
# => 0          = disables custom detection frequency (use Microsoft default value of 22 hours)
# => 1-22       = enables custom detection frequency with specified value
default['wsus_client']['detection_frequency']                      = 22

# Defines the day of the week to schedule update install.
# => :every_day = updates will be installed every day
# => :sunday    = updates will be installed every sunday
# => :monday    = updates will be installed every monday
# => :tuesday   = updates will be installed every tuesday
# => :wednesday = updates will be installed every wednesday
# => :thursday  = updates will be installed every thursday
# => :friday    = updates will be installed every friday
# => :saturday  = updates will be installed every saturday
default['wsus_client']['schedule_install_day']                     = :every_day
# Defines the time of day in 24-hour format to schedule update install. (0-23)
default['wsus_client']['schedule_install_time']                    = 0
# Defines the time in minutes to wait at startup before applying update from a missed scheduled time
# => 0          = attempt the missed installation during the next scheduled installation time
# => 1-60       = time in minutes to wait before applying missed
default['wsus_client']['schedule_retry_wait']                      = 0

# Defines the time in minutes of the restart warning countdown after reboot-required updates automatic install
# => 0          = use default value of 5 minutes
# => 1-30       = set restart countdown to specified value
default['wsus_client']['reboot_warning']                           = 5
# Defines time in minutes between prompts for a scheduled restart
# => 0          = use default value of 10 minutes
# => 1-1440     = set prompts period to specified value
default['wsus_client']['reboot_prompt_timeout']                    = 10

# Define action performed by the update recipe
# This can be a combination of: nothing, download & install
default['wsus_client']['update']['action']                        = %i[download install]
# Time in seconds alloted to the download operation before failing.
default['wsus_client']['update']['download_timeout']               = 3600
# Time in seconds alloted to the install operation before failing.
default['wsus_client']['update']['install_timeout']                = 3600
# Indicate whether to reboot or not after update install.
default['wsus_client']['update']['handle_reboot']                  = false
# The amount of time (in minutes) to delay the reboot.
default['wsus_client']['update']['reboot_delay']                   = 1
