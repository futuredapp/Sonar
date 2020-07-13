Pod::Spec.new do |s|
  s.name             = "Sonar"
  s.version          = "5.2.0"
  s.summary          = "Radar style view written in swift"

  s.description      = <<-DESC
                        Simple radar style view written in swift
                       DESC

  s.homepage         = "https://github.com/futuredapp/Sonar"
  s.screenshots     = "https://github.com/futuredapp/Sonar/raw/master/Documentation/screenshot.png", "https://github.com/futuredapp/Sonar/raw/master/Documentation/sonar-animation.gif"
  s.license          = 'MIT'
  s.author           = { "Aleš Kocur" => "aleskocur@icloud.com" }
  s.source           = { :git => "https://github.com/futuredapp/Sonar.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/Futuredapps'

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.swift_version = '5.0'

  s.source_files = 'Sources/Sonar/*'
end
