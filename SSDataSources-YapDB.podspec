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
  
  s.homepage         = "https://github.com/shsteven/SSDataSources-YapDB"
  s.license          = 'MIT'
  s.author           = { "Steven Zhang" => "sz@tectusdreamlab.com" }
  s.source           = { :git => "https://github.com/shsteven/SSDataSources-YapDB.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.dependency 'SSDataSources', '~> 0.8.0'
  s.dependency 'YapDatabase', '~> 2.8.1'
end
