Pod::Spec.new do |s|
  s.name             = 'flutter_unity_widget'
  s.version          = '4.0.0'
  s.summary          = 'Flutter unity 3D widget'
  s.description      = 'Flutter unity 3D widget for embedding unity in flutter'
  s.homepage         = 'http://xraph.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rex Isaac Raphael' => 'rex.raphael@outlook.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.vendored_frameworks = 'UnityFramework.framework'
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version = '5.0'
end
