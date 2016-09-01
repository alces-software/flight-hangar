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
  class Parameter
    class << self
      def [](name)
        (Hangar.context.caches.parameters ||= load)[name]
      end
      def load
        {}.tap do |h|
          YAML.load_file(File.join(Hangar.dbroot,'tables',"parameters.yml")).each do |p|
            # ignore parameters that are currently being provided as resources.
            next if p['resource'] && !Hangar.context.parameter_inclusions.include?(p['name'])
            h[p['name']] = new(p)
          end
        end
      end
    end

    attr_accessor :name, :label, :description, :type, :group_name, :order
    attr_accessor :pattern, :error, :min, :max, :default, :options, :noecho
    def initialize(h)
      self.name = h['name']
      self.label = h['label']
      self.description = h['description']
      self.type = h['type'] || "String"
      self.group_name = h['group']
      self.order = h['order'] || 1000
      self.pattern = h['pattern']
      self.error = h['error']
      self.min = h['min']
      self.max = h['max']
      self.default = h['default']
      self.options = h['options']
      self.noecho = h['noecho']
    end

    def group
      @group ||= Group[group_name]
    end

    def options
      case @options
      when Array
        @options
      when Hash
        Map[@options['name']].map.keys.reject(&(@options['exclude']||[]).method(:include?))
      end
    end

    def to_h
      {
        "Description" => Hangar.render(description),
        "Type" => type
      }.tap do |h|
        if default
          v = Hangar.render(default.to_s)
          h['Default'] = v unless v == ''
        end
        h['ConstraintDescription'] = Hangar.render(error) if error
        case type
        when "String"
          h['AllowedPattern'] = pattern if pattern
          h['MaxLength'] = Hangar.render(max.to_s) if max
          h['MinLength'] = Hangar.render(min.to_s) if min
          h['AllowedValues'] = options if options
          h['NoEcho'] = noecho if noecho
        when "Number"
          h['MinValue'] = Hangar.render(min.to_s) if min
          h['MaxValue'] = Hangar.render(max.to_s) if max
        end
      end
    end

    def to_a
      [name, to_h]
    end

    def <=>(other)
      [self.order, self.label] <=> [other.order, other.label]
    end
  end
end
