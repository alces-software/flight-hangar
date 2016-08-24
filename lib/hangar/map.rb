#==============================================================================
# Copyright (C) 2016 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Flight Hangar.
#
# Alces Flight Hangar is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Flight Hangar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Flight Hangar, please visit:
# https://github.com/alces-software/flight-hangar
#==============================================================================
require 'yaml'

module Hangar
  class Map
    class << self
      def [](name)
        (@cache ||= load)[name] || (raise "No mapping found: #{name}")
      end
      def load
        {}.tap do |h|
          YAML.load_file(File.join(Hangar.dbroot,'tables',"maps.yml")).each do |p|
            h[p['name']] = new(p)
          end
        end
      end
    end

    attr_accessor :name, :map
    def initialize(h)
      self.name = h['name']
      self.map = render(h['map'])
    end

    def to_a
      [name, map]
    end

    private
    def render(input)
      {}.tap do |output|
        input.each do |k,v|
          output[Hangar.render(k)] = {}.tap do |h|
            v.each do |k1, v1|
              h[k1] = String === v1 ? Hangar.render(v1) : v1
            end
          end
        end
      end
    end
  end
end
