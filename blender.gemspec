Gem::Specification.new do |s|
  s.version            = '0.17'
  s.date               = Time.now
  
  s.name               = 'blender'
  s.summary            = 'Blender gives you efficient, production-ready CSS and/or JavaScript assets.'
  s.description        = 'Blender is like ant or make for the front-end. It aggregates and compresses CSS and/or JavaScript assets for a site into efficient, production-ready files.'
  
  s.authors            = 'Blake Elshire & Chris Griego'
  s.email              = 'belshire@gmail.com'
  s.homepage           = 'http://github.com/front-end/front-end-blender/tree/master'
  s.rubyforge_project  = 'frontendblender'
  
  s.files              = ['README.rdoc', 'MIT-LICENSE', 'bin/blend', 'lib/front_end_architect/blender.rb', 'lib/front_end_architect/hash.rb', 'lib/yui/LICENSE', 'lib/yui/yuicompressor.jar']
  s.autorequire        = 'front_end_architect/blend'
  s.executables        << 'blend'
  s.default_executable = 'blend'
  
  s.add_dependency 'mime-types', '>= 1.15'
  s.add_dependency 'colored',    '>= 1.1'
  s.requirements << 'Java, v1.4 or greater'
end
