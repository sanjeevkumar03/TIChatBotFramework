
use_frameworks!

target 'TIChatBot' do
    pod 'XMPPFramework', :git => 'https://github.com/robbiehanson/XMPPFramework.git', :tag => '4.1.0', :modular_headers => true, :inhibit_warnings => true
   pod 'SDWebImage', '~> 5.18.10', :modular_headers => true, :inhibit_warnings => true
   pod 'SwiftyXMLParser', '~> 5.6.0', :modular_headers => true, :inhibit_warnings => true
   pod 'IQKeyboardManagerSwift', '~>7.0.0', :modular_headers => true, :inhibit_warnings => true
   pod 'ProgressHUD', '~>14.1.0', :modular_headers => true, :inhibit_warnings => true
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
  end
  installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
              if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < 13.0
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
              end
             end
        end
 end
end