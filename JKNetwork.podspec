#
#  Be sure to run `pod spec lint JKNetworking.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
   s.name         = "JKNetwork"
  s.version      = "0.0.6"
  s.summary      = "Secondary packaging."
  s.homepage     = "https://github.com/JekinChou/JKNetWorking"
  s.author       = { "zhangjie" => "454200568@qq.com" }
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.platform = :ios, '8.0'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.source       = { :git => "https://github.com/JekinChou/JKNetWorking.git", :tag => "#{s.version}" }
  s.source_files = "JKNetworking/JKNetworkingKit","*"
  s.dependency "AFNetworking", "~>3.0.0"

end
