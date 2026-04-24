# LogicalInkSDK

`LogicalInkSDK` is used to view forms from eCapture. This repository distributes the `LogicalInkSDK.xcframework`.

## SDK Version
- **SDK Version**: 9.0.0.21
- **Built**: 2026-04-15
- **Swift 6.1 artifact**: built with Xcode 16.4 (swiftlang-6.1.2.1.2)
- **Swift 6.3 artifact**: built with Xcode 26.4 (swiftlang-6.3.0.123.5)

## Which Version Do I Use?

| Your Xcode Version | Swift Version | Manual Artifact | CocoaPods Subspec |
|--------------------|---------------|--------------------------------------|-------------------|
| Xcode 16.x         | Swift 6.1.x   | `swift6.1/LogicalInkSDK.xcframework` | `Swift6_1` |
| Xcode 26.x         | Swift 6.3.x   | `swift6.3/LogicalInkSDK.xcframework` | `Swift6_3` |

## Installation

### CocoaPods (Recommended)

You can integrate `LogicalInkSDK` into your project using [CocoaPods](https://cocoapods.org). Based on your Swift version, specify the appropriate subspec in your `Podfile`. Since this pod is not published to the central trunk, you will need to point to the git repository:

**For Swift 6.1 (Xcode 16.x):**
```ruby
target 'YourApp' do
  use_frameworks!
  pod 'LogicalInkSDK/Swift6_1', :git => 'https://github.com/firofame/LogicalInkSDK.git', :tag => '9.0.0.21'
end
```

**For Swift 6.3 (Xcode 26.x):**
```ruby
target 'YourApp' do
  use_frameworks!
  pod 'LogicalInkSDK/Swift6_3', :git => 'https://github.com/firofame/LogicalInkSDK.git', :tag => '9.0.0.21'
end
```

*Note: If no subspec is specified, `Swift6_1` will be used by default.*

### Manual Integration

1. Drag the correct `LogicalInkSDK.xcframework` into your project.
2. In your target settings → **General** → **Frameworks, Libraries, and Embedded Content**:
   Set the framework to **Embed & Sign**.
3. No additional dependencies are required — all internal dependencies are statically linked.
