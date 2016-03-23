Pod::Spec.new do |s|
  s.name             = "AppSession"
  s.version          = "0.1.0"
  s.summary          = "A lightweight key-value store to share data across ViewControllers and or SKScenes"
  s.description      = "A lightweight key-value store to share data across ViewControllers and or SKScenes; combine it with a caching API for greater performance."
  s.homepage         = "https://github.com/taywils/AppSession"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "taywils" => "DemetriousWilson@gmail.com" }
  s.source           = { :git => "https://github.com/taywils/AppSession.git", :tag => s.version.to_s }
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.source_files     = 'Pod/Classes/**/*'
  s.resource_bundles = { 'AppSession' => ['Pod/Assets/*.png'] }
end
