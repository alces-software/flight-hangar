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
require 'hangar/resource'
require 'hangar/group'
require 'hangar/output'
require 'yaml'
require 'json'

module Hangar
  class Template
    class << self
      def load(name)
        new(YAML.load_file(File.join(Hangar.dbroot,'templates',"#{name}.yml")))
      end
    end

    attr_accessor :resource_names, :output_names, :description, :profiles, :inputs
    def initialize(h)
      self.profiles = h['profiles'] || []
      self.description = h['description']
      self.resource_names = h['resources']
      self.inputs = h['inputs'] || []
      self.output_names = h['outputs']
    end

    def render(pretty: false)
      Hangar.context.clear
      if inputs.any?
        rejector = lambda {|o| inputs.include?(o)}
        Resource.collators[Resource] = Collator.new(Resource, rejector)
        Hangar.context.parameter_inclusions = inputs
      end
      Hangar.with_profiles(profiles) do
        if pretty
          JSON.pretty_generate(to_h)
        else
          to_h.to_json
        end
      end
    end

    private

    def resources
      @resources ||= [].tap do |a|
        resource_names.each do |r|
          res = Resource[r]
          unless res.nil?
            a.concat(res.resources)
            a << res
          end
          a.uniq!
        end
      end
    end

    def maps
      @maps ||= [].tap do |a|
        resources.each do |r|
          a.concat(r.maps).uniq!
        end
        conditions.each do |c|
          a.concat(c.maps).uniq!
        end
      end
    end

    def parameters
      @parameters ||= [].tap do |a|
        resources.each do |r|
          a.concat(r.parameters).uniq!
        end
        unless Hangar.fetch('AdditionalParameters',[]).empty?
          a.concat(Hangar.fetch('AdditionalParameters').map(&Parameter.method(:[]))).uniq!
        end
        a.concat(inputs.map(&Parameter.method(:[])).compact).uniq!
      end.reject {|p| resources.map(&:name).include?(p.name) }
    end

    def conditions
      @conditions ||= [].tap do |a|
        resources.each do |r|
          a.concat(r.conditions).uniq!
        end
      end
    end

    def outputs
      @outputs ||= output_names.map(&Output.method(:[]))
    end

    def to_h
      {
        'Description' => description
      }.tap do |h|
        if parameters.any?
          h['Metadata'] = metadata
          h['Parameters'] = parameters.sort.map(&:to_a).to_h
        end
        h['Conditions'] = conditions.sort.map(&:to_a).to_h if conditions.any?
        h['Mappings'] = maps.sort.map(&:to_a).to_h if maps.any?
        h['Resources'] = resources.sort.map(&:to_a).to_h
        h['Outputs'] = outputs.sort.map(&:to_a).to_h if outputs.any?
      end
    end

    def metadata
      {
        "AWS::CloudFormation::Interface" => {
          "ParameterGroups" => [].tap do |a|
            parameters.map(&:group).uniq.sort.each do |grp|
              a << {
                "Label" => {"default": grp.label},
                "Parameters" => parameters.select{|p|p.group == grp}.sort.map(&:name)
              }
            end
          end,
          "ParameterLabels" => {}.tap do |h|
            parameters.sort.each do |p|
              h[p.name] = {"default": p.label}
            end
          end
        }
      }
    end
  end
end
