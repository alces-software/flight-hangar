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
require 'hangar/cli'
require 'hangar/render_context'

module Hangar
  class << self
    def root
      File.join(File.dirname(__FILE__), '..')
    end

    def dbroot
      File.join(File.dirname(__FILE__), '..', 'db')
    end

    def render(tpl)
      ERB.new(tpl).result(BasicObject.new.instance_eval { Kernel.binding })
    end

    def profiles
      @profiles ||= ['share']
    end

    def with_profiles(profiles, &block)
      old_profiles = self.profiles
      @profiles = profiles + self.profiles
      block.call.tap do
        @profiles = old_profiles
      end
    end

    def context
      @render_context ||= RenderContext.new
    end

    def fetch(key, default = nil)
      if values.key?(key)
        values[key]
      elsif !default.nil?
        default
      else
        raise "Required configuration value not found: #{key}"
      end
    end

    def values
      @values ||= YAML.load_file(File.join(dbroot,'config','defaults.yml'))
    end
  end
end
