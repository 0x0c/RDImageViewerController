#
# Be sure to run `pod lib lint RDImageViewerController.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "RDImageViewerController"
  s.version          = "0.2.8"
  s.summary          = "Simple but powerful image viewer."
  s.homepage         = "https://github.com/0x0c/RDImageViewerController"
  # s.screenshots     = "https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/1.png", "https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/2.png", "https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/view_and_image.png"
  s.license          = 'MIT'
  s.author           = { "Akira Matsuda" => "akira.m.itachi@gmail.com" }
  s.source           = { :git => "https://github.com/0x0c/RDImageViewerController.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m}'
  s.public_header_files = 'Pod/Classes/**/*.h'
end
