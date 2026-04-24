Pod::Spec.new do |s|
  s.name         = "LogicalInkSDK"
  s.version      = "9.0.0.21"
  s.summary      = "LogicalInkSDK is used to view forms from eCapture."
  s.description  = <<-DESC
                   A longer description of LogicalInkSDK.
                   LogicalInkSDK is used to view forms from eCapture.
                   DESC
  s.homepage     = "https://github.com/firofame/LogicalInkSDK"
  s.license      = { :type => "MIT", :text => "Copyright (c) 2026 Firoz Ahmed" }
  s.author       = { "Firoz Ahmed" => "firofame@gmail.com" }
  s.source       = { :git => "https://github.com/firofame/LogicalInkSDK.git", :tag => s.version.to_s }
  s.platform     = :ios, "17.0"
  s.default_subspec = 'Swift6_1'

  s.subspec 'Swift6_1' do |ss|
    ss.vendored_frameworks = 'swift6.1/LogicalInkSDK.xcframework'
  end

  s.subspec 'Swift6_3' do |ss|
    ss.vendored_frameworks = 'swift6.3/LogicalInkSDK.xcframework'
  end
end
