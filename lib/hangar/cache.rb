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
module Hangar
  module Cache
    def [](name)
      Hangar.profiles.find do |profile|
        v = ((@cache ||= {})[profile] ||= Hash.new do |h,k|
               begin
                 h[k] = load(profile, k)
               rescue Errno::ENOENT
                 nil
               end
             end)[name]
        break v unless v.nil?
      end
    end

    def load(profile, name)
      raise NotImplementedError, "Includers should implement #load method"
    end

    def collators
      @collators ||= Hash.new do |h,k|
        h[k] = Collator.new(k)
      end
    end

    def collate(collection, type, &block)
      collators[type].collate(collection, &block)
    end
  end
end
