# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'EladTraining' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
	pod 'Firebase/Auth'
	pod 'Firebase/Database'
	pod 'MaterialComponents'
	pod "FlagPhoneNumber"
	pod 'MDatePickerView'
	
	
  # Pods for EladTraining

end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
        end
    end
end
