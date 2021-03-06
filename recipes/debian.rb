#
# Cookbook Name:: mirror
# Recipe:: debian
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

package 'git'

group 'debian-archvsync'

user 'debian-archvsync' do
  home '/share/debian-archvsync'
  shell '/bin/bash'
  system true
  group 'debian-archvsync'
end

git '/share/debian-archvsync' do
  repository 'https://ftp-master.debian.org/git/archvsync.git/'
end

bash 'chown_debian-archvsync' do
  code 'chown -R debian-archvsync:debian-archvsync /share/debian-archvsync'
end

directory '/share/debian-archvsync' do
  recursive true
  owner 'debian-archvsync'
  group 'debian-archvsync'
end

cookbook_file '/share/debian-archvsync/etc/ftpsync.conf' do
  source 'ftpsync.conf'
  owner 'debian-archvsync'
  group 'debian-archvsync'
  mode '0644'
end

directory '/share/debian' do
  recursive true
  owner 'debian-archvsync'
  group 'debian-archvsync'
end

cron_d 'debian-repo-sync' do
  minute 0
  hour '*/6'
  command '/share/debian-archvsync/bin/ftpsync'
  user 'debian-archvsync'
end
