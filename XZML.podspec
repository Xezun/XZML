#
# Be sure to run `pod lib lint XZML.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZML'
  s.version          = '2.0.0'
  s.summary          = 'XZML 富文本标记语言'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  XZML 是一款轻量级的 iOS 富文本解决方案，可以快速方便的直接通过字符串构造富文本，用于解决 iOS 开发中，构造富文本繁琐，及不能直接下发富文本的问题。
                       DESC

  s.homepage         = 'https://github.com/Xezun/XZML'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'developer@xezun.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZML.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  
  s.dependency 'XZDefines/XZMacro'
  s.dependency 'XZExtensions/UIColor'
  
  s.subspec 'Code' do |ss|
    ss.source_files = 'XZML/Code/**/*.{h,m}'
    ss.private_header_files = 'XZML/Code/**/Core/*.h'
  end
  
  # s.resource_bundles = {
  #   'XZML' => ['XZML/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

