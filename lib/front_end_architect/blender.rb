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
require 'pathname'
require 'zlib'

module FrontEndArchitect
  class Blender
    VERSION      = '0.11'
    
    FILTER_REGEX = /filter: ?[^?]+\(src=(['"])([^\?'"]+)(\?(?:[^'"]+)?)?\1,[^?]+\1\);/im
    IMPORT_REGEX = /@import(?: url\(| )(['"])([^\?'"]+)(\?(?:[^'"]+)?)?\1\)?(?:[^?;]+)?;/im
    URL_REGEX    = /url\((['"]?)([^\?'"]+)(\?(?:[^'"]+)?)?\1\)/im
    
    DEFAULT_OPTIONS = {
      :blendfile => 'Blendfile.yaml',
      :data      => false,
      :force     => false,
    }
    
    def initialize(opts)
      @options = DEFAULT_OPTIONS.merge(opts)
    end
    
    def blend
      elapsed = Benchmark.realtime do
        unless File.exists? @options[:blendfile]
          raise "Couldn't find '#{@options[:blendfile]}'"
        end
        
        blender = YAML::load_file @options[:blendfile]
        
        Dir.chdir(File.dirname(@options[:blendfile]))
        
        blender = flatten_blendfile(blender)
        
        blender.each do |output_name, sources|
          output_name = Pathname.new(output_name).cleanpath.to_s
          
          output_new       = false
          gzip_output_name = output_name + '.gz'
          
          # Checks the type flag and if the current file meets the type requirements continues
          if output_name.match '.' + @options[:file_type].to_s
            file_type = output_name.match(/\.css/) ? 'css' : 'js'
            
            # Checks if output file exists and checks the mtimes of the source files to the output file if new creates a new file
            if File.exists?(output_name) && (!@options[:gzip] || File.exists?(gzip_output_name))
              output_files = []
              output_files << File.mtime(output_name)
              output_files << File.mtime(gzip_output_name) if @options[:gzip] && File.exists?(gzip_output_name)
              
              oldest_output = output_files.sort.first
              
              sources.each do |i|
                if File.mtime(i) > oldest_output
                  output_new = true
                  break
                end
              end
              
              if output_new || @options[:force]
                create_output(output_name, sources, file_type)
              else
                puts "Skipping: #{output_name}"
                puts "Skipping: #{gzip_output_name}" if @options[:gzip]
              end
            else
              create_output(output_name, sources, file_type)
            end
          end
        end
      end
      
      puts sprintf('%.5f', elapsed) + ' seconds'
    end
    
    def generate
      if File.exists?(@options[:blendfile]) && !@options[:force]
        raise "'#{@options[:blendfile]}' already exists"
      end
      
      blend_files = Hash.new
      
      Find.find(Dir.getwd) do |f|
        basename = File.basename(f)
        
        if FileTest.directory?(f) && (basename[0] == ?. || basename.match(/^(yui|tinymce|dojo|wp-includes|wp-admin|mint)$/) || (File.basename(f) == 'rails' && File.basename(File.dirname(f)) == 'vendor'))
          Find.prune
        elsif !(basename.match(/[-.](pack|min)\.(css|js)$/) || basename.match(/^(sifr\.js|ext\.js|mootools.*\.js)$/))
          # TODO Test for 'pack.js' and 'min.css' where the folder name serves as the identifier
          f.gsub!(Dir.getwd.to_s + '/', '')
          
          if File.extname(f) == '.css'
            min_file = f.sub(/\.css$/, '-min.css')
            
            blend_files[min_file] = [f]
          elsif File.extname(f) == '.js'
            min_file = f.sub(/\.js$/, '-min.js')
            
            blend_files[min_file] = [f]
          end
        end
      end
      
      blend_files = blend_files.sort
      
      File.open(@options[:blendfile], 'w') do |blendfile|
        blend_files.each do |block|
          blendfile << "#{block[0]}:\r\n  - #{block[1]}\r\n"
        end
      end
    end
    
    protected
    
    def flatten_blendfile(value, key=nil, context=[])
      if value.is_a? Hash
        context << key unless key.nil?
        
        new_hash = {}
        
        value.each do |k, v|
          new_hash.merge! flatten_blendfile(v, k, context.dup)
        end
        
        new_hash
      else
        prefix = context.join(File::SEPARATOR)
        prefix += File::SEPARATOR unless context.empty?
        
        value.each_index do |i|
          value[i] = prefix + value[i]
        end
        
        return { (prefix + key) => value }
      end
    end
    
    def create_output(output_name, sources, type)
      output = ''
      
      File.open(output_name, 'w') do |output_file|
        # Determine full path of the output file
        output_path = Pathname.new(File.expand_path(File.dirname(output_name)))
        imports = ''
        
        sources.each do |i|
          if File.extname(i) == '.css'
            processed_output, processed_imports = process_css(i, output_path)
            output  << processed_output
            imports << processed_imports
          else
            output << IO.read(i)
          end
        end
        
        if File.extname(output_name) == '.css' && !imports.empty?
          output.insert(0, imports)
        end
        
        # Compress
        libdir = File.join(File.dirname(File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__), *%w[.. .. lib])
        
        IO.popen("java -jar #{libdir}/yui/yuicompressor.jar #{@options[:yuiopts]} --type #{type}", 'r+') do |io|
          io.write output
          io.close_write
          
          output = io.read
          
          if File.extname(output_name) == '.css'
            output.gsub! ' and(', ' and (' # Workaround for YUI Compressor Bug #1938329
            output.gsub! '*/;}',  '*/}'    # Workaround for YUI Compressor Bug #1961175
            
            if @options[:data]
              output = output.gsub(URL_REGEX) do
                if (!$2.include?('.css'))
                  mime_type    = MIME::Types.type_for($2)
                  url_contents = make_data_uri(IO.read($2), mime_type[0])
                else
                  url_contents = $2
                end
                  %Q!url(#{url_contents})!
              end
            end
          end
          
          output_file << output
        end
        
        if $? == 32512 # command not found
          raise "\nBlender requires Java, v1.4 or greater, to be installed for YUI Compressor"
        end
      end
      
      puts output_name
      
      if @options[:gzip]
        output_gzip = output_name + '.gz'
        
        Zlib::GzipWriter.open(output_gzip) do |gz|
          gz.write(output)
        end
        
        puts output_gzip
      end
    end
    
    def process_css(input_file, output_path)
      # Determine full path of input file
      input_path    = Pathname.new(File.dirname(input_file))
      input         = IO.read(input_file)
      found_imports = ''
      
      # Find filter statements and append cache busters to URLs
      if @options[:cache_buster]
        input = input.gsub(FILTER_REGEX) do |filter|
          uri       = $2
          full_path = File.expand_path($2, File.dirname(input_file))
          buster    = make_cache_buster(full_path, $3)
          new_path  = uri.to_s + buster
          
          %Q!filter='#{new_path}'!
        end
      end
      
      # Handle @import statements URL rewrite and adding cache busters
      input = input.gsub(IMPORT_REGEX) do |import|
        uri        = $2
        asset_path = Pathname.new(File.expand_path(uri, input_path))
        
        if (output_path != input_path)
          new_path = asset_path.relative_path_from(output_path)
          
          if @options[:cache_buster]
            buster = make_cache_buster(asset_path, $3)
            import.gsub!(uri, new_path.to_s + buster)
          else
            import.gsub!(uri, new_path)
          end
        else
          if @options[:cache_buster]
            buster = make_cache_buster(asset_path, $3)
            import.gsub!(uri, asset_path.to_s + buster)
          end
        end
        
        found_imports << import
        
        %Q!!
      end
      
      if output_path == input_path
        if @options[:data]
          input = input.gsub(URL_REGEX) do |uri|
            new_path = File.expand_path($2, File.dirname(input_file))
            
            %Q!url(#{new_path}#{$3})!
          end
        elsif @options[:cache_buster]
          input = input.gsub(URL_REGEX) do
            uri = $2
            
            if (@options[:cache_buster])
              buster   = make_cache_buster(uri, $3)
              new_path = uri.to_s + buster
            end
            
            %Q!url(#{new_path})!
          end
        end
        
        return input, found_imports
      else
        # Find all url(.ext) in file and rewrite relative url from output directory
        input = input.gsub(URL_REGEX) do |url|
          uri = $2
          
          if @options[:data]
            # If doing data conversion rewrite url as an absolute path
            new_path = File.expand_path(uri, File.dirname(input_file))
          else
            asset_path = Pathname.new(File.expand_path(uri, File.dirname(input_path)))
            new_path   = asset_path.relative_path_from(output_path)
            
            if @options[:cache_buster]
              buster   = make_cache_buster(asset_path, $3)
              new_path = new_path.to_s+buster
            end
          end
          
          %Q!url(#{new_path})!
        end
        
        return input, found_imports
      end
    end
    
    def make_cache_buster(asset_path, query_string)
      unless query_string.nil?
        query_string += '&'
      else
        query_string = '?'
      end
      
      if @options[:cache_buster] == :mtime
        file_mtime = File.mtime(asset_path).to_i
        buster = query_string + file_mtime.to_s
      else
        buster = query_string + @options[:cache_buster]
      end
      
      return buster
    end
    
    def make_data_uri(content, content_type)
      "data:#{content_type};base64,#{Base64.encode64(content)}".gsub("\n", '')
    end
  end
end
