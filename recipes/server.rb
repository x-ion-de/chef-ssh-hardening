#
# Cookbook Name:: ssh
# Recipe:: ssh_server.rb
#
# Copyright 2012, Dominik Richter
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

package "openssh-server"

directory "/etc/ssh" do
  mode 0555
  owner "root"
  group "root"
  action :create
end

template "/etc/ssh/sshd_config" do
  source "opensshd.conf.erb"
  mode 0400
  owner "root"
  group "root"
end


directory "/root/.ssh" do
  mode 0500
  owner "root"
  group "root"
  action :create
end

keys = search("users","ssh-key:*").map{|v| 
  Chef::Log.info "ssh_server: installing ssh-keys for user #{v['id']}"
  v['ssh-key'] 
}
Chef::Log.info "ssh_server: not setting up any ssh keys" if keys.empty?

template "/root/.ssh/authorized_keys" do
  source "authorized_keys.erb"
  mode 0400
  owner "root"
  group "root"
  variables(
    :keys => keys
  )
  only_if{ not keys.empty? }
end