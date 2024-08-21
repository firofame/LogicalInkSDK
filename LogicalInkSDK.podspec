Pod::Spec.new do |s|
  s.name         = "LogicalInkSDK"
  s.version      = "7.6.6.4"
  s.summary      = "A short description of LogicalInkSDK."
  s.description  = <<-DESC
                   A longer description of LogicalInkSDK.
                   DESC
  s.homepage     = "https://github.com/firofame/LogicalInkSDK"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Firoz Ahmed" => "firofame@gmail.com" }
  s.source       = { :http => "https://github.com/firofame/LogicalInkSDK/releases/download/7.6.6.4/LogicalInkSDK.zip" }
  s.platform     = :ios, "13.0"
  s.swift_version = "5.0"

  # Source files
  s.source_files = "LogicalInkSDK/**/*.{h,m,swift}"

  # Frameworks
  s.vendored_frameworks = [
    "CDMarkdownKit.framework",
    "LogicalInkSDK.framework",
    "ObjcExceptionBridging.framework",
    "RappleProgressHUD.framework",
    "Reachability.framework",
    "TOCropViewController.framework",
    "XCGLogger.framework"
  ]

  s.resources = ['LogicalInkSDKBundle.bundle', 'TOCropViewControllerBundle.bundle']
end
