Pod::Spec.new do |s|

s.name              = "mamba"
s.version           = "0.6.1"
s.summary           = "mamba - a library for parsing, validating and editing HLS manifests"

s.description       = <<-DESC
mamba is a library for parsing, validating and editing HLS manifests
DESC

s.homepage          = "https://github.comcast.com/viper-player/helio_ios"
s.license           = "Private (Comcast Propietary)"
s.author            = "Player Platform iOS Team - VIPER Comcast"

s.platform          = :ios, '9.0'
s.source            = { :git => "https://github.comcast.com/viper-player/helio_ios.git", :tag => "#{s.version}" }
s.source_files      = "Classes", "mamba/**/*.{h,m,swift}"
s.framework         = "AVFoundation"

end
