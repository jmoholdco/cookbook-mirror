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

RSpec.describe 'mirror::webserver' do
  let(:chef_run) { ChefSpec::SoloRunner.new(opts).converge(described_recipe) }

  %w(6.7 7.0 7.1.1503).each do |version|
    context "on centos v#{version}" do
      let(:opts) { { platform: 'centos', version: version } }
      include_examples 'converges successfully'

      it 'installs the httpd package' do
        expect(chef_run).to install_yum_package 'httpd'
      end

      it 'links /var/www/html to /share' do
        expect(chef_run).to create_link('/var/www/html').with(
          to: '/share'
        )
      end

      it 'creates the httpd.conf' do
        expect(chef_run).to create_template('/etc/httpd/conf/httpd.conf')
      end

      it 'starts and enables the service' do
        expect(chef_run).to start_service('httpd')
        expect(chef_run).to enable_service('httpd')
      end

      it 'creates the index.html file' do
        expect(chef_run).to create_cookbook_file('/var/www/html/index.html')
      end
    end
  end
end
