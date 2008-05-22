Gem::Specification.new do |s|
  s.version            = '0.8'
  s.date               = Time.now
  
  s.name               = 'blender'
  s.summary            = 'Blender gives you efficient, production-ready CSS and/or JavaScript assets.'
  s.description        = 'Blender is like ant or make for the front-end. It aggregates and compresses CSS and/or JavaScript assets for a site into efficient, production-ready files.'
  
  s.authors            = 'Blake Elshire & Chris Griego'
  s.email              = 'belshire@gmail.com'
  s.homepage           = 'http://github.com/front-end/front-end-blender/tree/master'
  
  s.files              = [ "README", "MIT-LICENSE", "bin/blend", "lib/yui/yuicompressor.jar", "lib/yui/LICENSE" ]
  s.executables        << 'blend'
  s.default_executable = 'blend'
  
  s.add_dependency('mime-types', '>= 1.15')
  s.requirements << 'Java, v1.4 or greater'
end
