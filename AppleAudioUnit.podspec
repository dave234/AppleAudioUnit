#
# Be sure to run `pod lib lint AppleAudioUnit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AppleAudioUnit'
  s.version          = '0.1.1'
  s.summary          = 'A base implementation of Apple\'s AUAudioUnit to simplify the creation of custom audio units.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
In order to create an Apple AUv3 audio unit, an AUAudioUnit subclass must be created. The base AUAudioUnit implementation does not work out of the box. These subclasses manage buffers, per event rendering, and parameter states, including ramping.
                       DESC

  s.homepage         = 'https://github.com/dave234/AppleAudioUnit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dave O\'Neill' => 'daveoneill234@gmail.com' }
  s.source           = { :git => 'https://github.com/dave234/AppleAudioUnit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'

  s.swift_version = '5.0'
  s.source_files = 'AppleAudioUnit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'AppleAudioUnit' => ['AppleAudioUnit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'AVFoundation', 'AudioToolBox'
  s.dependency 'Cwift'
end
