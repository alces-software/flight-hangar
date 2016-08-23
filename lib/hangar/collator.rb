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
  class Collator
    def initialize(type, rejector = nil)
      @type = type
      @rejector = rejector
    end

    def collate(collection, &block)
      [].tap do |a|
        collection.each do |e|
          next if reject?(e)
          r = @type[e]
          unless r.nil?
            a << r
            block.call(r,a) unless block.nil? || a.include?(r)
          end
        end
      end
    end

    private
    def reject?(o)
      @rejector && @rejector.call(o)
    end
  end
end
