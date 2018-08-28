use_frameworks!

workspace 'EllipticCurveKit'

def pods
	pod 'BigInt'

	# CryptoSwift is used for Hash functions (sha256)
	pod 'CryptoSwift'
end

target 'EllipticCurveKit' do

	project 'EllipticCurveKit.xcodeproj'
  
	pods

  target 'EllipticCurveKitTests' do
		inherit! :search_paths
  end

end

target 'ExampleiOS' do

	project 'Example/ExampleiOS'

	pods

	target 'ExampleiOSTests' do
		inherit! :search_paths
	end

end