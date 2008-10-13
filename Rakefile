# Copyright (c) 2008 Blake Elshire, Chris Griego
# 
# Blender is freely distributable under the terms of an MIT-style license.
# For details, see http://www.opensource.org/licenses/mit-license.php

$:.unshift File.join(File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__), *%w[lib])

require 'rubygems'
require 'hoe'
require 'front_end_architect/blender'

hoe = Hoe.new('blender', FrontEndArchitect::Blender::VERSION) do |p|
  p.author      = ['Blake Elshire', 'Chris Griego']
  p.email       = 'blender@front-end-architect.com'
  p.summary     = 'Blender outputs efficient, production-ready CSS and/or JavaScript assets.'
  p.description = 'Blender is like ant or make for the front-end. It aggregates and compresses CSS and/or JavaScript assets for a site into efficient, production-ready files.'
  p.url         = 'http://www.front-end-architect.com/blender/'
  
  p.extra_deps << ['mime-types', '>= 1.15']
  p.extra_deps << ['colored',    '>= 1.1']
  
  p.spec_extras[:requirements] = 'Java, v1.4 or greater'
  
  p.remote_rdoc_dir = '' # Release to root
  p.rdoc_pattern    = /^(lib\/front_end_architect|bin|ext)|txt$/
end

task :update_gemspec do
  File.open("#{hoe.name}.gemspec", 'w') do |gemspec|
    gemspec << hoe.spec.to_ruby
  end
end

task :debug_changes do
  puts hoe.changes
end
