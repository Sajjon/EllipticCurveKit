Pod::Spec.new do |s|
    s.name                      = 'EllipticCurveKit'
    s.version                   = '0.0.1'
    s.ios.deployment_target     = "8.0"
    s.osx.deployment_target     = "10.9"
    s.tvos.deployment_target    = "9.0"
    s.watchos.deployment_target = "2.0"
    s.license                   = { :type => 'Apache License, Version 2.0', :file => 'LICENSE.md' }
    s.summary                   = 'Elliptic Curve Cryptography in pure Swift'
    s.homepage                  = 'https://github.com/Sajjon/EllipticCurveKit'
    s.author                    = 'Alex Cyon'
    s.source                    = { :git => 'https://github.com/Sajjon/EllipticCurveKit.git', :tag => spec.version.to_s }
    s.source_files              = 'Source/*.swift'
    s.social_media_url          = 'https://twitter.com/alexcyon'

    s.dependency 'EquationKit', :git => 'https://github.com/Sajjon/EquationKit.git'
    s.dependency 'BigInt',      :git => 'https://github.com/attaswift/BigInt.git'
    s.dependency 'CryptoSwift', :git => 'https://github.com/krzyzanowskim/CryptoSwift.git'
end