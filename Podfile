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