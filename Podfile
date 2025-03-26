# Uncomment the next line to define a global platform for your project
platform :ios, '16.0'

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end

target 'ToDoCat' do
  use_frameworks!

  # Pods for ToDoCat
  pod 'SnapKit', '~> 5.7.0'
  pod 'RealmSwift'
  pod 'IQKeyboardManagerSwift'
  pod 'FSCalendar'
  pod 'Alamofire'
  pod 'AcknowList'
  pod 'Toast-Swift', '~> 5.1.1'
end
