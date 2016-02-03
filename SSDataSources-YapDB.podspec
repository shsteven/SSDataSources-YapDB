#
# Be sure to run `pod lib lint SSDataSources-YapDB.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SSDataSources-YapDB"
  s.version          = "0.1.0"
  s.summary          = "A SSDataSource subclass to plug into YapDatabase View."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  

  s.homepage         = "https://github.com/shsteven/SSDataSources-YapDB"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Steven Zhang" => "sz@tectusdreamlab.com" }
  s.source           = { :git => "https://github.com/shsteven/SSDataSources-YapDB.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/shsteven'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SSDataSources-YapDB' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SSDataSources', '~> 0.8.5'
  s.dependency 'YapDatabase', '~> 2.8.1'
end
