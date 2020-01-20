#
# Be sure to run `pod lib lint Sonar.podspec' to ensure this is a
# valid spec before submitting.

Pod::Spec.new do |s|
  s.name             = "Sonar"
  s.version          = "5.0.0"
  s.summary          = "Radar style view written in swift"

  s.description      = <<-DESC
                        Simple radar style view written in swift
                       DESC

  s.homepage         = "https://github.com/futuredapp/Sonar"
  s.screenshots     = "https://raw.githubusercontent.com/futuredapp/Sonar/master/screenshot.png", "https://raw.githubusercontent.com/futuredapp/Sonar/master/sonar-animation.gif"
  s.license          = 'MIT'
  s.author           = { "Aleš Kocur" => "aleskocur@icloud.com" }
  s.source           = { :git => "https://github.com/futuredapp/Sonar.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Futuredapps'

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.swift_version = '5.0'

  s.source_files = 'Pod/Classes/**/*'
end
