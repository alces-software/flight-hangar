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
  class Group
    class << self
      def [](name)
        (Hangar.context.caches.groups ||= load)[name]
      end
      def load
        {}.tap do |h|
          YAML.load_file(File.join(Hangar.dbroot,'tables',"groups.yml")).each do |k,v|
            h[k] = new(k,v)
          end
        end
      end
    end

    attr_accessor :key, :label, :order
    def initialize(k, h)
      self.key = k
      self.label = h['label']
      self.order = h['order'] || 1000
    end

    def <=>(other)
      [self.order, self.label] <=> [other.order, other.label]
    end
  end
end
