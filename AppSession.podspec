Pod::Spec.new do |s|
  s.name             = "AppSession"
  s.version          = "0.1.1"
  s.summary          = "A lightweight key-value store to share data across ViewControllers and or SKScenes"
  s.description      = "AppSession was created due to my frustrations with existing tools that either needed to access the disk for caching, required modifying my code to implement some strange Protocol(s) and or couldn't handle storing reference types. So during the creation/debugging of one of my SpriteKit games I started building a class that let me initialize a SKScene based on any arbitrary game data; I extracted the code from my game and re-named it AppSession." 
  s.homepage         = "https://github.com/taywils/SwiftAppSession"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "taywils" => "DemetriousWilson@gmail.com" }
  s.source           = { :git => "https://github.com/taywils/SwiftAppSession.git", :tag => s.version.to_s }
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.source_files     = 'Pod/Classes/**/*'
  # s.resource_bundles = { 'AppSession' => ['Pod/Assets/*.png'] }
end
