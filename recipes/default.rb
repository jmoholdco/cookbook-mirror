#
# Cookbook Name:: mirror
# Recipe:: default
#
# The MIT License (MIT)
#
# Copyright (c) 2015 J. Morgan Lieberthal
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

include_recipe 'rsync'
cache_path = Chef::Config[:file_cache_path]
version = node['platform_version'].to_i
arch = node['mirror']['arch']
path_to_mirror = "#{node['mirror']['dir']}/#{node['platform_version']}"

tree = node['mirror']['sub_dirs'].map do |dir|
  "#{path_to_mirror}/#{dir}/#{arch}"
end

directory node['mirror']['dir'] do
  recursive true
end

directory "#{path_to_mirror}" do
  recursive true
end

link "#{node['mirror']['dir']}/#{version}" do
  to "#{node['mirror']['dir']}/#{node['platform_version']}"
end

tree.each do |dir|
  directory dir do
    recursive true
  end
end

remote_file "#{cache_path}/everything.iso" do
  source "#{node['mirror']['seed']['url']}/#{node['mirror']['seed']['file']}"
  owner 'root'
  group node['root_group']
  checksum node['mirror']['seed']['checksum']
  not_if { ::File.exist?("#{node['mirror']['dir']}/#{version}/os/#{arch}/GPL") }
end

directory '/tmp/mnt' do
  recursive true
end

mount '/tmp/mnt' do
  device "#{cache_path}/everything.iso"
  fstype 'iso9660'
  options %w( ro loop )
  not_if { ::File.exist?("#{node['mirror']['dir']}/#{version}/os/#{arch}/GPL") }
end

bash 'rsync_repo_iso' do
  code "rsync -avHPS /tmp/mnt/ #{node['mirror']['dir']}/#{version}/os/#{arch}/"
  notifies :umount, 'mount[/tmp/mnt]', :immediately
  not_if { ::File.exist?("#{node['mirror']['dir']}/#{version}/os/#{arch}/GPL") }
end

template '/usr/local/bin/repo-sync' do
  source 'repo-sync.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(mirror_dir: path_to_mirror,
            remote_host: node['mirror']['sync_repo'],
            version: node['platform_version'])
end
