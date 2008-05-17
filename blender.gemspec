Gem::Specification.new do |s|
   s.name        = 'blender'
   s.version     = '0.5.2'
   s.date        = Time.now
   s.authors     = 'Blake Elshire & Chris Griego'
   s.email       = 'belshire@gmail.com'
   s.summary     = 'Blender gives you efficient, production-ready CSS and/or JavaScript assets.'
   s.homepage    = 'http://github.com/front-end/front-end-blender/tree/master'
   s.description = 'Blender is like ant or make for the front-end. It aggregates and compresses CSS and/or JavaScript assets for a site into efficient, production-ready files.'
   s.files       = [ "README", "MIT-LICENSE", "bin/blend", "lib/yuicompressor.jar" ]
   s.executables << 'blend'
end