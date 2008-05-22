# Copyright (c) 2008 Chris Griego
#           (c) 2008 Blake Elshire
# 
# Blender is freely distributable under the terms of an MIT-style license.
# For details, see http://www.opensource.org/licenses/mit-license.php

require 'rubygems'
require 'yaml'
require 'base64'
require 'benchmark'
require 'mime/types'
require 'find'

module FrontEndArchitect
  class Blender
    VERSION = '0.8.3'
    
    DEFAULT_OPTIONS = {
      :blendfile => 'blender.yaml',
      :data      => false,
      :force     => false,
    }
    
    attr_reader :options
    
    def initialize(opts)
      @options = DEFAULT_OPTIONS.merge(opts)
    end
    
    def blend
      if @options[:generate]
        create_blendfile
      end
      
      elapsed = Benchmark.realtime do
        unless File.exists? @options[:blendfile]
          puts "Couldn't find '#{@options[:blendfile]}'"
          exit 1
        end
        
        blender = YAML::load_file @options[:blendfile]
        
        Dir.chdir(File.dirname(@options[:blendfile]))
        
        blender.each do |output_name, sources|
          output_new = false
          
          # Checks the type flag and if the current file meets the type requirements continues
          if output_name.match "." + @options[:file_type].to_s
            file_type = output_name.match(/\.css/) ? "css" : "js"
            
            # Checks if output file exists and checks the mtimes of the source files to the output file if new creates a new file
            if File.exists? output_name
              sources.each do |i|
                if File.mtime(i) > File.mtime(output_name)
                  output_new = true
                  break
                end
              end
              
              if output_new || @options[:force]
                create_output(output_name, sources, file_type)
              else
                puts "Skipping: #{output_name}"
              end
            else
              create_output(output_name, sources, file_type)
            end
          end
        end
      end
      
      puts sprintf("%.5f", elapsed) + " seconds"
    end
    
    protected
    
    def create_blendfile
      if File.exists?(@options[:blendfile]) && !@options[:force]
        puts "'#{@options[:blendfile]}' already exists"
        exit 1
      end
      
      blend_files = Hash.new
      
      Find.find(Dir.getwd) do |f|
        f.gsub!(Dir.getwd.to_s+"/", "")
        if File.extname(f) == ".css"
          file = f.split(".css")
          min_file = file[0] + "-min.css"
          blend_files[f] = [min_file]
        end
        
        if File.extname(f) == ".js"
          file = f.split(".js")
          min_file = file[0] + "-min.js"
          blend_files[f] = [min_file]
        end
        
        Find.prune if File.basename(f).index('.') == 0
      end
      
      File.open(@options[:blendfile], 'w') { |f| YAML.dump(blend_files, f) }
      
      exit 0
    end
    
    # TODO Change to work with directory hashes (css/: [ colors.css, layout.css ])
    def create_output(output_name, sources, type)
      File.open(output_name, 'w') do |output_file|
        output = ''
        
        sources.each do |i|
          output << IO.read(i)
        end
        
        # Compress
        libdir = File.join(File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__), *%w[.. .. lib])
        
        IO.popen("java -jar #{libdir}/yui/yuicompressor.jar #{@options[:yuiopts]} --type #{type}", mode="r+") do |io|
          io.write output
          io.close_write
          
          output = io.read
          
          if File.extname(output_name) == ".css"
            output.gsub! ' and(', ' and (' # Workaround for YUI Compressor Bug #1938329
            output.gsub! '/**/;}', '/**/}' # Workaround for YUI Compressor Bug #1961175
            
            if @options[:data]
              output = output.gsub(/url\(['"]?([^?']+)['"]+\)/im) do
                uri = $1
                mime_type = ''
                
                # Make the URI absolute instead of relative. TODO Seems kinda hacky is there a better way?
                uri.gsub! "../", ""
                
                # Figure out the mime type.
                mime_type = MIME::Types.type_for(uri)
                
                url_contents = make_data_uri(IO.read(uri), mime_type[0])
                
                %Q!url("#{url_contents}")!
              end
            end
          end
          
          output_file << output
        end
      end
      
      puts output_name
    end
    
    def make_data_uri(content, content_type)
      "data:#{content_type};base64,#{Base64.encode64(content)}".gsub("\n", '')
    end
  end
end
