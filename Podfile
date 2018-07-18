# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

workspace 'SwiftCrypto'

def pods()
	pod 'BigInt'
  pod 'CryptoSwift'
end

target 'SwiftCrypto' do
	project 'SwiftCrypto.xcodeproj'
  use_frameworks!

	pods

  target 'SwiftCryptoTests' do
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