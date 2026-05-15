Pod::Spec.new do |s|
  s.name             = 'UnityFramework'
  s.version          = '0.0.1'
  s.summary          = 'Unity Framework'
  s.description      = 'Unity Framework for Flutter'
  s.homepage         = 'https://unity.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Unity' => 'unity@unity.com' }
  s.source           = { :path => '.' }
  s.platform         = :ios, '15.0'
  s.vendored_frameworks = 'build/Release-iphoneos/UnityFramework.framework'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/../../ios_xcode/build/Release-iphoneos"' }
end
