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
require 'hangar/collator'
require 'hangar/parameter'
require 'hangar/condition'
require 'hangar/map'
require 'hangar/snippet'
require 'yaml'

module Hangar
  class Resource
    class << self
      include Cache
      def load(profile, name)
        new(name, YAML.load_file(File.join(Hangar.dbroot,'profiles',profile,'resources',"#{name}.yml")))
      end
    end

    attr_accessor :name, :after, :depends, :condition, :conditions, :maps, :type, :properties
    def initialize(name, h)
      self.name = name
      self.after = h['after'] || []
      self.depends = h['depends'] || []
      self.conditions = h['conditions'] || []
      self.condition = h['condition']
      self.maps = h['maps'] || []
      self.type = h['type']
      self.properties = JSON.parse("{#{Hangar.render(h['properties'])}}") if h['properties']
    end

    def resources
      collate(@depends + @after, Resource) do |res, collation|
        collation.concat(res.resources).uniq!
      end
    end

    def after
      collate(@after, Resource)
    end

    def parameters
      collate(@depends, Parameter).tap do |collation|
        conditions.each do |c|
          collation.concat(c.parameters).uniq!
        end
      end
    end

    def conditions
      collate(@conditions, Condition) do |res, collation|
        collation.concat(res.conditions).uniq!
      end
    end

    def maps
      collate(@maps, Map)
    end

    def to_h
      {
        "Type" => type
      }.tap do |h|
        h["Condition"] = condition if condition
        h["DependsOn"] = after.map(&:name) if after.any?
        h["Properties"] = properties if properties
      end
    end

    def to_a
      [name, to_h]
    end

    private
    def collate(*a, &b)
      self.class.collate(*a, &b)
    end
  end
end
