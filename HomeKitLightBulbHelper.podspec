Pod::Spec.new do |s|
  s.name             = 'HomeKitLightBulbHelper'
  s.version          = '0.1.2'
  s.summary          = 'HomeKit Light Bulb Helper.'
  s.description      = <<-DESC
HomeKit Light Bulb Helper. Only retrieve rooms with light bulbs that supports hue or saturation.
                       DESC

  s.homepage         = 'https://github.com/rnaharro/HomeKitLightBulbHelper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ricardo N.' => 'rnaharro@icloud.com' }
  s.source           = { :git => 'https://github.com/rnaharro/HomeKitLightBulbHelper.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/AppDelegate'
  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.source_files = 'HomeKitLightBulbHelper/Classes/**/*'
end
