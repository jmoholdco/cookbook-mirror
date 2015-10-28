default['mirror']['el_version'] = node['platform_version']
default['mirror']['dir'] = '/share/centos'
default['mirror']['arch'] = 'x86_64'
default['mirror']['seed'] = {
  url: 'ftp://nfs.jmorgan.org/pub',
  file: 'CentOS-7-x86_64-Everything-1503-01.iso',
  checksum: '8c3f66efb4f9a42456893c658676dc78fe12b3a7eabca4f187de4855d4305cc7'
}
default['mirror']['sync_repo'] = 'mirrors.kernel.org'

case node['platform_version'].to_i
when 7
  default['mirror']['sub_dirs'] = %w( atomic
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
when 6
  default['mirror']['sub_dirs'] = %w( SCL
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
