#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint boc_flutter_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'botion_flutter_plugin'
  s.version          = '0.0.2'
  s.summary          = 'The official BotionCaptcha flutter plugin project.'
  s.description      = <<-DESC
The official flutter plugin project for BotionCaptcha.
                       DESC
  s.homepage         = 'https://www.botion.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'botion' => 'mobile@botion.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'BotionCaptcha-xcframework'
  s.platform = :ios, '9.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
