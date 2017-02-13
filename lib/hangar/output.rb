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
  class Output
    class << self
      def [](name)
        (Hangar.context.caches.outputs ||= load)[name]
      end
      def load
        {}.tap do |h|
          YAML.load_file(File.join(Hangar.dbroot,'tables',"outputs.yml")).each do |p|
            h[p['name']] = new(p)
          end
        end
      end
    end

    attr_accessor :name, :description, :value, :resource, :attribute, :raw_value, :condition
    def initialize(h)
      self.name = h['name']
      self.description = h['description']
      self.value = h['value']
      self.resource = h['resource']
      self.attribute = h['attribute']
      self.raw_value = h['raw_value']
      self.condition = h['condition']
    end

    def to_h
      {
        "Description" => description
      }.tap do |h|
        h['Value'] =
          if value
            {"Ref": value}
          elsif attribute
            {"Fn::GetAtt": [resource, attribute]}
          else
            JSON.parse("{#{raw_value}}")
          end
        if condition
          if Hangar.context.parameter_inclusions.include?(condition)
            h['Condition'] = condition
          end
        end
      end
    end

    def to_a
      [name, to_h]
    end

    def <=>(other)
      self.name <=> other.name
    end
  end
end
