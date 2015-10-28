require 'net/http'

module MirrorCookbook
  module Helpers
    def fetch_repo_structure(mirror = 'http://mirrors.kernel.org/centos')
      response = Net::HTTP.get_response(URI.parse("#{mirror}/dir_sizes"))
      return 'Net::HTTP Error!' unless response.code == '200'
      _format(response.body)
    end

    private

    def _format(response)
      response.split("\n").keep_if { |d| d =~ /\t[5-9]/ }.map do |entry|
        size, dir = entry.split("\t")
        {
          size: size,
          dir: dir
        }
      end
    end
  end
end
