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
require 'hangar/cache'

module Hangar
  class Condition
    class << self
      include Cache
      def load(profile, name)
        new(name, YAML.load_file(File.join(Hangar.dbroot,'profiles',profile,'conditions',"#{name}.yml")))
      end
    end

    attr_accessor :name, :parameters, :conditions, :condition, :maps
    def initialize(name, h)
      self.name = name
      self.parameters = h['parameters'] || []
      self.maps = h['maps'] || []
      self.conditions = h['conditions'] || []
      self.condition = JSON.parse("{#{h['condition']}}")
    end

    def parameters
      collate(@parameters, Parameter).tap do |collation|
        conditions.each do |c|
          collation.concat(c.parameters).uniq!
        end
      end
    end

    def maps
      collate(@maps, Map)
    end

    def conditions
      collate(@conditions, Condition) do |res, collation|
        collation.concat(res.conditions).uniq!
      end
    end

    def to_a
      [name, condition]
    end

    def <=>(other)
      self.name <=> other.name
    end

    private
    def collate(*a, &b)
      self.class.collate(*a, &b)
    end
  end
end
