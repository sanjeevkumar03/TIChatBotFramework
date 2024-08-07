
Pod::Spec.new do |spec|
spec.name         = "TIChatBot"
spec.version      = "0.0.1"
spec.summary      = "TIChatbot Framework"
spec.description  = "Want to experience chatbot in your iOS app! Now install chatbot in your application using this beautiful framework."
spec.homepage = "https://github.com/xavient/IOSVirtualAssistant"
spec.license      = { :type => "MIT", :file => "LICENSE" }
#spec.author             = { "sanjeevkumar03" => "sanjeev.kumar03@telusinternational.com" }
spec.author    = "TelusDigital"
spec.platform     = :ios, "13.0"
spec.ios.deployment_target = "13.0"

spec.source       = { :path => '.' }

# Published binaries
spec.vendored_frameworks = "TIChatBot.xcframework"

spec.framework = "UIKit"
spec.dependency 'XMPPFramework', :git => 'https://github.com/robbiehanson/XMPPFramework.git', :tag => '4.1.0'
spec.dependency 'SDWebImage', '~> 5.18.10'
spec.dependency 'SwiftyXMLParser', '~> 5.6.0'
spec.dependency 'IQKeyboardManagerSwift', '~>7.0.0'
spec.dependency 'ProgressHUD', '~>14.1.0'

spec.swift_version = "5.0"
spec.requires_arc = true

end
