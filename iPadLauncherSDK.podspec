Pod::Spec.new do |s|
  s.name         = "iPadLauncherSDK"
  s.version      = "9.0.0.21"
  s.summary      = "iPadLauncherSDK is used to view forms from eCapture."
  s.description  = <<-DESC
                   A longer description of iPadLauncherSDK.
                   iPadLauncherSDK is used to view forms from eCapture.
                   DESC
  s.homepage     = "https://github.com/firofame/LogicalInkSDK"
  s.license      = { :type => "MIT", :text => "Copyright (c) 2026 Firoz Ahmed" }
  s.author       = { "Firoz Ahmed" => "firofame@gmail.com" }
  s.source       = { :git => "https://github.com/firofame/LogicalInkSDK.git", :tag => s.version.to_s }
  s.platform     = :ios, "17.0"
  s.swift_version = "6.1"

  # 9.0.0.21 distribution ships a self-contained XCFramework.
  s.vendored_frameworks = "LogicalInkSDK.xcframework"
 
end
