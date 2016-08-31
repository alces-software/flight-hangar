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
require 'fileutils'
require 'commander'
require 'hangar/template'

module Hangar
  class CLI
    extend Commander::UI
    extend Commander::UI::AskForClass
    extend Commander::Delegates

    program :name, 'hangar'
    program :version, '0.0.1'
    program :description, 'Generate CloudFormation templates for Alces Flight appliances'

    command :render do |c|
      c.syntax = 'hangar render [options] NAME'
      c.option '--config NAME', 'Choose a config file'
      c.option '--values KEYVALUE', 'Override a config value'
      c.option '--all', 'Render all templates'
      c.option '--output DIRECTORY', 'Render to a file in an output directory'
      c.option '--[no-]pretty', 'Render templates prettily or not'

      c.action do |args, options|
        if options.config
          puts "Using config: #{options.config}"
          Hangar.values.merge!(YAML.load_file(File.join(Hangar.dbroot,'config',"#{options.config}.yml")))
        end
        if options.values
          options.values.split(',').each do |val|
            puts "Overriding value: #{val}"
            k, v = val.split('=')
            h = Hangar.values
            ks = k.split('.')
            ks[0..-2].each do |kk|
              if ! Hash === h[kk]
                h[kk] = {}
              end
              h = h[kk]
            end
            h[ks.last] = v || ''
          end
        end

        output_dir = options.output || File.join(Hangar.root, "output")
        FileUtils.mkdir_p(output_dir)

        if options.all
          Dir[File.join(Hangar.dbroot,'templates','*.yml')].each do |tf|
            t = File.basename(tf,'.yml')
            o = File.join(output_dir, "#{t}.json")
            File.open(o, 'w') do |f|
              puts "Wrote: #{o}"
              f.puts Hangar::Template.load(t).render(pretty: options.pretty)
            end
          end
        elsif options.output
          o = File.join(output_dir, "#{args[0]}.json")
          File.open(o,'w') do |f|
            puts "Wrote: #{o}"
            f.puts Hangar::Template.load(args[0]).render(pretty: options.pretty)
          end
        else
          puts Hangar::Template.load(args[0]).render(pretty: options.pretty)
        end
      end
    end
  end
end
