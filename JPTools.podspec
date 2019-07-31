#
# Be sure to run `pod lib lint JPTools.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JPTools'
  s.version          = '0.1.1'
  s.summary          = 'Tools for JP'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    A collection of tools for JP
                       DESC

  s.homepage         = 'https://github.com/jokepran@163.com/JPTools'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jokepran' => 'jokepran@gmail.com' }
  s.source           = { :git => 'https://github.com/JokePran/JPTools.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'JPTools/Classes/**/*'

  s.subspec 'JPAudioPlayer' do |a|
      a.source_files = 'JPTools/Classes/JPAudioPlayer/**/*'
  end

  s.subspec 'JPPermenantThead' do |p|
      p.source_files = 'JPTools/Classes/JPPermenantThead/**/*'
  end

  s.subspec 'JPProgressHUD' do |p|
      p.source_files = 'JPTools/Classes/JPProgressHUD/**/*'
  end

  s.subspec 'JPSQLTools' do |t|
      t.source_files = 'JPTools/Classes/JPSQLTools/**/*'
  end

  s.subspec 'JPTimer' do |t|
      t.source_files = 'JPTools/Classes/JPTimer/**/*'
  end



  
  # s.resource_bundles = {
  #   'JPTools' => ['JPTools/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
