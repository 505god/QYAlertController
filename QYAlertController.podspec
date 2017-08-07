#
#  Be sure to run `pod spec lint QYAlertController.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "QYAlertController"
  s.version      = "1.0"
  s.summary      = "针对系统的UIAlertController进行封装：普通的alert、toast、带输入框的alert、actionsheet"
  s.homepage     = "https://github.com/505god/QYAlertController"

  s.license      = "MIT"
  s.author       = { "qcx" => "18915410342@126.com" }
  s.platform     = :ios
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/505god/QYAlertController.git", :tag => "1.0" }
  s.source_files  = 'QYAlertController/Classes/*.{h,m}'
  s.requires_arc = true

end
