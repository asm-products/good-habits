#
# Be sure to run `pod spec lint GTHRectHelpers.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
  s.name         = "GTHRectHelpers"
  s.version      = "0.0.1"
  s.summary      = "Utility macros for working with CGRect, CGSize, CGPoint etc..."
  s.homepage     = "http://github.com/goodtohear/GTHRectHelpers"

  s.license      = 'MIT (example)'
  s.author       = { "Michael Forrest" => "michael.forrest@gmail.com" }
  s.source       = { :git => "https://github.com/goodtohear/GTHRectHelpers.git", :tag => "0.0.1" }

  s.platform     = :ios

  s.source_files = 'Classes', 'Classes/**/*.{h,m}'

end
