# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

workspace 'EllipticCurveKit'

def pods()
	pod 'BigInt'
  	pod 'CryptoSwift'
end

target 'EllipticCurveKit' do
	project 'EllipticCurveKit.xcodeproj'
  use_frameworks!

	pods

  target 'EllipticCurveKitTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'ExampleiOS' do
	project 'Example/ExampleiOS'
	use_frameworks!

	pods

	target 'ExampleiOSTests' do
		inherit! :search_paths
	end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
        	config.build_settings['ENABLE_TESTABILITY'] = 'YES'
        end
    end
end