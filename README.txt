= Front-End Blender

== What is Blender?

Blender is like ant or make for the front-end. It aggregates and compresses
CSS and/or JavaScript assets for a site into efficient, production-ready files.

== The Blendfile

The Blendfile, named Blendfile.yaml by default, is the configuration file
that tells Blender which source files are combined into which output files.
The file uses the YAML format. The output file is listed as hash key and
source files are the hash values as an array. Here is a sample Blendfile:

  # Blendfile.yaml for www.boldpx.com
  _behavior:
    _global-min.js:
      - ../_vendor/jquery/jquery.js
      - ../_vendor/shadowbox/src/js/adapter/shadowbox-jquery.js
      - ../_vendor/shadowbox/src/js/shadowbox.js
      - _global.js
      - _analytics.js
      - ../vendor/google-analytics/ga.js
  _style:
    _global:
      min.css:
        - ../../_vendor/shadowbox/src/css/shadowbox.css
        - typography.css
        - typography-print.css
        - colors.css
        - colors-print.css
        - layout-screen.css
        - layout-print.css

== Usage

  Usage: blend [options]
      -g, --generate                   Generate a stub Blendfile
      -f, --file FILE                  Use specified Blendfile
      -r, --root ROOT                  Specify the path to the web root directory
      -t, --type TYPE                  Select file type to blend (css, js)
      -m, --min [MINIFIER]             Select minifier to use (yui, none)
      -c, --cache-buster [BUSTER]      Add cache busters to URLs in CSS
          --force                      Don't allow output files to be skipped
          --yui=YUIOPTS                Pass arguments to YUI Compressor
  
  Experimental:
      -d, --data                       Convert url(file.ext) to url(data:) in CSS
      -z, --gzip                       Additionally generate gzipped output files
  
  Meta:
      -h, --help                       Show this message
      -V, --version                    Show the version number

== Examples

In your site directory run 'blend' to minify CSS and JavaScript.
  blend

Other examples:
  blend --generate
  blend --yui='--preserve-semi'
  blend -t css
  blend -t css -d
  blend -f public/Blendfile.yaml

== Installation

To install the RubyGem, run the following at the command line (you may need to use a command such as su or sudo):
  gem install blender

If you're using Windows, you'll also want to run the following to get colored command line output:
  gem install win32console

* Java[http://java.com/en/] v1.4 or greater is required
* Ruby[http://www.ruby-lang.org/en/downloads/] v1.8.6 or greater is required
* RubyGems[http://rubygems.org/read/chapter/3] v1.2 or greater is recommended

== License

Copyright (c) 2008 Blake Elshire, Chris Griego

Blender is freely distributable under the terms of an MIT-style license.
For details, see http://www.opensource.org/licenses/mit-license.php
