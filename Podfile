# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'

target 'ios' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'AppCenter'
  pod 'SVProgressHUD'
  pod 'LGSideMenuController'
  pod 'PhoneNumberKit'
  pod 'SwiftClient', :git => 'https://github.com/givtnl/SwiftClient.git'
  pod 'TrustKit'
  pod 'SwipeCellKit', '~> 2.5.4'
  pod 'MaterialShowcase'
  pod 'ReachabilitySwift'
  pod 'Mixpanel-swift'
  pod "MonthYearPicker", '~> 4.0.2'
  pod "GivtCodeShare", :path => 'givt.apps.shared/GivtCodeShare'

  # Pods for ios
  target 'ios.tests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
