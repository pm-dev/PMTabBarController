Pod::Spec.new do |s|
  s.name             = "PMTabBarController"
  s.version          = "0.0.5"
  s.summary          = "A container for view controllers. Upon panning left or right, the user will flip through view controllers as if rotating a prism."
  s.homepage         = "https://github.com/petermeyers1/#{s.name}"
  s.license          = 'MIT'
  s.author           = { "Peter Meyers" => "petermeyers1@gmail.com" }
  s.source           = { :git => "https://github.com/petermeyers1/#{s.name}.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc     = true
  s.source_files     = 'Classes/**/*.{h,m}'
  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'Classes/**/*.h'
  s.frameworks       = 'Foundation', 'CoreGraphics', 'UIKit'
  s.dependency 'PMUtils'
  s.dependency 'PMCircularCollectionView'
end
