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
  before do
    stub_command('mount | grep /tmp/mnt').and_return(0)
  end
  %w(7.0).each do |version|
    context "on redhat v#{version}" do
      let(:opts) { { platform: 'redhat', version: version } }
      let(:full) { version }
      let(:major) { version.to_i }
      include_examples 'converges successfully'
      describe 'the directory structure' do
        it 'creates the base directory' do
          expect(chef_run).to create_directory('/share/centos')
        end

        it 'creates the directory for the version' do
          expect(chef_run).to create_directory("/share/centos/#{version}")
        end

        it 'links the major version to the latest minor version' do
          expect(chef_run).to create_link("/share/centos/#{major}").with(
            to: "/share/centos/#{version}"
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

          subdir.map { |d| "/share/centos/#{v}/#{d}/x86_64" }.each do |dir|
            it "creates the directory #{dir}" do
              expect(chef_run).to create_directory(dir)
            end
          end
        end

        describe 'populating the mirror' do
          let(:seed) { chef_run.remote_file('/var/chef/cache/everything.iso') }
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

          it 'remote file notifes the seed media to /tmp/mount' do
            expect(seed).to notify('mount[/tmp/mnt]').to(:mount).immediately
          end

          describe 'the seed mount' do
            let(:mount) { chef_run.mount('/tmp/mnt') }
            it 'does nothing by default' do
              expect(mount).to do_nothing
            end

            it 'has the right device' do
              expect(mount.device).to eq '/var/chef/cache/everything.iso'
            end

            it 'has the right fstype' do
              expect(mount.fstype).to eq 'iso9660'
            end

            it 'has the right mount options' do
              expect(mount.options).to eq %w( ro loop )
            end
          end

          it 'includes the rsync cookbook' do
            expect(chef_run).to include_recipe 'rsync'
          end

          describe 'the first rsync' do
            let(:rsync) { chef_run.bash('rsync_repo_iso') }
            it 'runs the bash to sync the iso with the repo' do
              expect(chef_run).to run_bash('rsync_repo_iso').with(
                code: "rsync -avHPS /tmp/mnt/ /share/centos/#{major}/os/x86_64/"
              )
            end

            it 'notifies the mount to unmount' do
              expect(rsync).to notify('mount[/tmp/mnt]').to(:umount).immediately
            end
          end

          it 'creates the script to sync the repository' do
            expect(chef_run).to create_template('/usr/local/bin/repo-sync')
          end

          it 'creates a cron job to sync the repo' do
            expect(chef_run).to create_cron('repo-sync').with(
              minute: '0',
              hour: '4,8,12',
              command: '/usr/local/bin/repo-sync',
              user: 'root'
            )
          end
        end
      end
    end
  end
end
