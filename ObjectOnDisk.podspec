#
# Be sure to run `pod lib lint ObjectOnDisk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ObjectOnDisk'
  s.version          = '0.1.0'
  s.summary          = 'Helps managing saving/loading an object to/from disk.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  ObjectOnDisk is a tool to help managing saving/loading an object to/from disk
                       DESC

  s.homepage         = 'https://github.com/BenMaer/ObjectOnDisk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ben Maer' => 'ben@resplendent.co' }
  s.source           = { :git => 'https://github.com/BenMaer/ObjectOnDisk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
  s.swift_version = '4.0'
  s.ios.deployment_target = '10.0'

  s.source_files = 'ObjectOnDisk/Classes/**/*'
  
  s.test_spec 'Tests' do |test_spec|
      test_spec.source_files = 'Example/Tests/*.swift'
  end
  
  # s.resource_bundles = {
  #   'ObjectOnDisk' => ['ObjectOnDisk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
