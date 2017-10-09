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
    def exclusions
      @exclusions ||= Hash.new {|h,k| h[k] = []}
    end
    def additions
      @additions ||= Hash.new {|h,k| h[k] = []}
    end

    def [](name)
      @exclusions = @additions = nil
      Hangar.profiles.find do |profile|
        v = ((Hangar.context.caches[self.name] ||= {})[profile] ||= Hash.new do |h,k|
               begin
                 o = load(profile, k)
                 h[k] = o
                 # if loaded item is a modifier, return nil, record modifications, try again
                 if o.respond_to?(:modifier?) && o.modifier?
                   o.exclusions.each do |a,v|
                     excluded = o.exclusions[a].reject {|t| additions[a].include?(t)}
                     exclusions[a].concat(excluded)
                   end
                   o.additions.each do |a,v|
                     added = o.additions[a].reject {|t| exclusions[a].include?(t)}
                     additions[a].concat(added)
                   end
                   h[k] = nil
                 else
                   exclusions.each {|a,v| o.instance_variable_get("@#{a}").delete_if {|e| v.include?(e)}}
                   additions.each {|a,v| o.instance_variable_get("@#{a}").concat(v).uniq!}
                   h[k] = o
                 end
               rescue Errno::ENOENT
                 h[k] = nil
               end
             end)[name]
        break v unless v.nil?
      end
    end

    def load(profile, name)
      raise NotImplementedError, "Includers should implement #load method"
    end

    def collators
      Hangar.context.caches.collators ||= Hash.new do |h,k|
        h[k] = Collator.new(k)
      end
    end

    def collate(collection, type, &block)
      collators[type].collate(collection, &block)
    end
  end
end
