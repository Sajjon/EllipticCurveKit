Pod::Spec.new do |spec|
    spec.name         = 'EllipticCurveKit'
    spec.version      = '0.0.1'
    spec.ios.deployment_target = "8.0"
    spec.osx.deployment_target = "10.9"
    spec.tvos.deployment_target = "9.0"
    spec.watchos.deployment_target = "2.0"
    spec.license      = { :type => 'MIT', :file => 'LICENSE.md' }
    spec.summary      = 'Elliptic Curve Cryptography in pure Swift'
    spec.homepage     = 'https://github.com/Sajjon/EllipticCurveKit'
    spec.author       = 'Alex Cyon'
    spec.source       = { :git => 'https://github.com/Sajjon/EllipticCurveKit.git', :tag => String(spec.version) }
    spec.source_files = 'sources/*.swift'
    spec.social_media_url = 'https://twitter.com/alexcyon'
    spec.dependency 'BigInt', '~> 3.1'
end