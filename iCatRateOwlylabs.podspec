Pod::Spec.new do |s|
  s.name                  = "iCatRateOwlylabs"
  s.version               = "0.0.3"
  s.summary               = "Example of creating own pod."
  s.homepage              = "https://github.com/OwlyLabs/catRate"
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { "Username" => "account@owlylabs.com" }
  s.platform              = :ios, '7.0'
  s.source                = { :git => "https://github.com/OwlyLabs/catRate.git", :tag => s.version.to_s }
  s.source_files          = 'Classes/*.{h,m}'
  s.public_header_files   = 'Classes/*.h'
  s.framework             = 'Foundation'
  s.requires_arc          = true
end