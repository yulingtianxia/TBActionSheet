Pod::Spec.new do |s|
s.name         = "TBActionSheet"
s.version      = "1.4.3"
s.summary      = "A Custom&Magical ActionSheet."
s.description  = <<-DESC
TBActionSheet is a small library that allows you to substitute Apple's uncustomizable UIActionSheet, with a beautiful and totally customizable actionsheet that you can use in your iOS app. The default style is iOS9, you can make your own style. Enjoy!
If you want your UIAlertController to be compatible with iOS7(even lower), you can just replace your UIAlertController with TBAlertController
DESC
s.homepage     = "https://github.com/yulingtianxia/TBActionSheet"

s.license = { :type => 'MIT', :file => 'LICENSE' }
s.author       = { "YangXiaoyu" => "yulingtianxia@gmail.com" }
s.social_media_url = 'https://twitter.com/yulingtianxia'
s.source       = { :git => "https://github.com/yulingtianxia/TBActionSheet.git", :tag => s.version.to_s }

s.platform     = :ios, '6.0'
s.requires_arc = true

s.source_files = "Source/**/*.{h,m}"
s.frameworks = 'Foundation', 'UIKit'

end