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

  s.homepage         = "https://github.com/thefuntasty/Sonar"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Aleš Kocur" => "aleskocur@icloud.com" }
  s.source           = { :git => "https://github.com/thefuntasty/Sonar.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.swift_version = '5.0'

  s.source_files = 'Pod/Classes/**/*'
end
