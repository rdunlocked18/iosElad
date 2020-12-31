# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'EladTraining' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
	pod 'Firebase/Auth'
	pod 'Firebase/Database'
	pod 'MaterialComponents'
	pod "FlagPhoneNumber"
	pod 'BulletinBoard' , '~> 5.0.0-rc.2'
	pod 'PMAlertController'
	pod 'Nuke', '~> 9.0'
	pod 'Toast-Swift', '~> 5.0.1'
	pod 'DateScrollPicker'
	pod 'DatePicker', '~> 1.3.0'
	pod 'SwiftDate', '~> 5.0'
	pod 'YPImagePicker'
	pod 'iOSDropDown'
	
	
  # Pods for EladTraining

end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
	    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
        end
    end
end
