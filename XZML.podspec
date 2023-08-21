#
# Be sure to run `pod lib lint XZML.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XZML'
  s.version          = '1.0.0'
  s.summary          = 'XZML 富文本描述语言'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                       通过 XZML 可以快速的通过字符串直接构造富文本，方便快捷直接。
                       DESC

  s.homepage         = 'https://github.com/Xezun/XZML'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Xezun' => 'developer@xezun.com' }
  s.source           = { :git => 'https://github.com/Xezun/XZML.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'XZ_FRAMEWORK=1' }
  s.dependency 'XZExtensions/UIColor'
  s.dependency 'XZExtensions/NSString'
  
  s.subspec 'Code' do |ss|
    ss.source_files = 'XZML/Code/**/*.{h,m}'
    # ss.project_header_files = 'XZML/Code/**/Private/*.{h,m}'
  end
  
  # s.resource_bundles = {
  #   'XZML' => ['XZML/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

