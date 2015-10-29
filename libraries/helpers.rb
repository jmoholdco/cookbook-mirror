require 'net/http'

module MirrorCookbook
  module Helpers
    # def all_versions_of(distro)
    #   VERSION_TABLE[distro]
    # end

    # def directory_structure_for(resource)
    #   if resource.versions == 'all'
    #     all_versions_of(resource.name).map { |d| "#{resource.path}/#{d}" }
    #   else
    #     resource.versions.map { |v| "#{resource.path}/#{v}" }
    #   end
    # end

    # def fetch_repo_structure(mirror = 'http://mirrors.kernel.org/centos')
    #   response = Net::HTTP.get_response(URI.parse("#{mirror}/dir_sizes"))
    #   return 'Net::HTTP Error!' unless response.code == '200'
    #   _format(response.body)
    # end

    # private

    # def _format(response)
    #   response.split("\n").keep_if { |d| d =~ /\t[5-9]/ }.map do |entry|
    #     size, dir = entry.split("\t")
    #     {
    #       size: size,
    #       dir: dir
    #     }
    #   end
    # end

    # VERSION_TABLE = {
    #   'centos' => %w( 2.1 3.1 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0 4.1 4.2 4.3 4.4
    #                   4.5 4.6 4.7 4.8 4.9 5.0 5.1 5.10 5.11 5.2 5.3 5.4 5.5 5.6
    #                   5.7 5.8 5.9 6.0 6.1 6.2 6.3 6.4 6.5 6.6 6.7 7.0.1406
    #                   7.1.1503 )
    # }
  end
end
