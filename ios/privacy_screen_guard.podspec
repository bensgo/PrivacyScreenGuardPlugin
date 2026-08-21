Pod::Spec.new do |s|
  s.name             = 'privacy_screen_guard'
  s.version          = '0.0.1'
  s.summary          = 'Protect sensitive Flutter content from screen capture.'
  s.description      = <<-DESC
Protect sensitive Flutter content from screen capture and background snapshots on iOS.
                       DESC
  s.homepage         = 'https://github.com/bensgo/PrivacyScreenGuardPlugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'bensgo' => 'xiaogaoleile@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  s.resource_bundles = {'privacy_screen_guard_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
