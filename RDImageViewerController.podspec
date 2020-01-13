#
# Be sure to run `pod lib lint RDImageViewerController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RDImageViewerController'
  s.version          = '5.0.0'
  s.summary          = 'Simple but powerful image viewer.'
  s.homepage         = 'https://github.com/0x0c/RDImageViewerController'
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!


  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Akira Matsuda' => 'akira.m.itachi@gmail.com' }
  s.source           = { :git => 'https://github.com/0x0c/RDImageViewerController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.source_files = 'RDImageViewerController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RDImageViewerController' => ['RDImageViewerController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

