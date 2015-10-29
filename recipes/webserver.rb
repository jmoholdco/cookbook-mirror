#
# Cookbook Name:: mirror
# Recipe:: webserver
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

yum_package 'httpd' do
  action :install
end

service 'httpd' do
  action [:enable, :start]
end

link '/var/www/html' do
  to '/share'
end

directory '/var/www/html/images' do
  recursive true
end

cookbook_file '/var/www/html/images/favicon.ico' do
  source 'favicon.ico'
  owner 'apache'
  group 'apache'
  mode '0644'
end

cookbook_file '/var/www/html/images/mirror.png' do
  source 'mirror.png'
  owner 'apache'
  group 'apache'
  mode '0644'
end

cookbook_file '/var/www/html/images/us.png' do
  source 'us.png'
  owner 'apache'
  group 'apache'
  mode '0644'
end

template '/etc/httpd/conf/httpd.conf' do
  source 'httpd.conf.erb'
  owner 'root'
  group node['root_group']
  notifies :restart, 'service[httpd]'
end

cookbook_file '/var/www/html/index.html' do
  source 'index.html'
  owner 'apache'
  group 'apache'
  mode '0644'
  notifies :restart, 'service[httpd]'
end
