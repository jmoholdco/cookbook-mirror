#
# Cookbook Name:: mirror
# Spec:: default
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

require 'spec_helper'

RSpec.describe 'mirror::default' do
  let(:chef_run) { ChefSpec::SoloRunner.new(opts).converge(described_recipe) }
  %w(6.7 7.0.1406 7.1.1503).each do |version|
    context "on centos v#{version}" do
      let(:opts) { { platform: 'centos', version: version } }
      let(:full) { version }
      let(:major) { version.to_i }
      include_examples 'converges successfully'
      describe 'the directory structure' do
        it 'creates the base directory' do
          expect(chef_run).to create_directory('/share/CentOS')
        end

        it 'creates the directory for the version' do
          expect(chef_run).to create_directory("/share/CentOS/#{version}")
        end

        it 'links the major version to the latest minor version' do
          expect(chef_run).to create_link("/share/CentOS/#{major}").with(
            to: "/share/CentOS/#{version}"
          )
        end

        describe 'the sub-directory structure' do
          v = version
          subdir = if version.to_i >= 7
                     %w( atomic
                         centosplus
                         cloud
                         cr
                         extras
                         fasttrack
                         isos
                         os
                         sclo
                         updates
                         virt )
                   else
                     %w( SCL
                         centosplus
                         cloud
                         contrib
                         cr
                         extras
                         fasttrack
                         isos
                         os
                         updates
                         xen4 )
                   end

          subdir.map { |d| "/share/CentOS/#{v}/#{d}/x86_64" }.each do |dir|
            it "creates the directory #{dir}" do
              expect(chef_run).to create_directory(dir)
            end
          end
        end

        describe 'populating the mirror' do
          it 'first downloads the remote file' do
            expect(chef_run).to create_remote_file('/var/chef/cache/everything.iso') # rubocop:disable Metrics/LineLength
              .with(
                checksum: '8c3f66efb4f9a42456893c658676dc78fe12b3a7eabca4f187de4855d4305cc7', # rubocop:disable Metrics/LineLength
                source: 'ftp://nfs.jmorgan.org/pub/CentOS-7-x86_64-Everything-1503-01.iso', # rubocop:disable Metrics/LineLength
                owner: 'root',
                group: chef_run.node['root_group']
              )
          end

          it 'creates the temporary mount directory' do
            expect(chef_run).to create_directory('/tmp/mnt')
          end

          it 'mounts the seed media to /tmp/mount' do
            expect(chef_run).to mount_mount('/tmp/mnt').with(
              device: '/var/chef/cache/everything.iso',
              fstype: 'iso9660',
              options: %w( ro loop )
            )
          end

          it 'includes the rsync cookbook' do
            expect(chef_run).to include_recipe 'rsync'
          end

          describe 'the first rsync' do
            let(:rsync) { chef_run.bash('rsync_repo_iso') }
            it 'runs the bash to sync the iso with the repo' do
              expect(chef_run).to run_bash('rsync_repo_iso').with(
                code: "rsync -avHPS /tmp/mnt/ /share/CentOS/#{major}/os/x86_64/"
              )
            end

            it 'notifies the mount to unmount' do
              expect(rsync).to notify('mount[/tmp/mnt]').to(:umount).immediately
            end
          end

          it 'creates the script to sync the repository' do
            expect(chef_run).to create_template('/usr/local/bin/repo-sync')
          end
        end
      end
    end
  end
end
