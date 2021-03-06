#
# Be sure to run `pod lib lint ASTextInputAccessoryView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = "ASTextInputAccessoryView"
    s.version          = "1.2.1"
    s.summary          = "Messages app input view recreated in Swift."
    s.description      = <<-DESC
Messages app input accessory view recreated in Swift.

Set as your chat ViewController's inputAccessoryView for a customizable and auto-resizing text input bar.

Powered by ASPlaceholderTextView and PMKVObserver
                       DESC

    s.homepage         = "https://github.com/davidseek/ASTextInputAccessoryView"
    s.license          = 'MIT'
    s.author           = { "Adam Share" => "ashare80@gmail.com" }
    s.source           = { :git => "https://github.com/davidseek/ASTextInputAccessoryView.git", :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/adamshare'

    s.platform     = :ios, '8.0'
    s.requires_arc = true

    s.source_files = 'Pod/Source/**/*'
    s.frameworks = 'UIKit'
    s.dependency 'PMKVObserver', '~> 2.0'
end
