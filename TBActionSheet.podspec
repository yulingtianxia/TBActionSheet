Pod::Spec.new do |s|
s.name         = "TBActionSheet"
s.version      = "1.2.0"
s.summary      = "A Custom UIActionSheet"
s.description  = <<-DESC
TBActionSheet is a custom action sheet. The default style is iOS9, you can make your own style.
If you want your UIAlertController to be compatible with iOS7(even lower), you can just replace your UIAlertController with TBAlertController
DESC
s.homepage     = "https://github.com/yulingtianxia/TBActionSheet"

s.license = { :type => 'MIT', :file => 'LICENSE' }
s.author       = { "YangXiaoyu" => "yulingtianxia@gmail.com" }
s.social_media_url = "http://yulingtianxia.com"
s.source       = { :git => "https://github.com/yulingtianxia/TBActionSheet.git", :tag => s.version.to_s }

s.platform     = :ios, '6.0'
s.requires_arc = true

s.source_files = "TBActionSheet/**/*.{h,m}", "TBAlertController/**/*.{h,m}", "Utils/**/*.{h,m}"
s.frameworks = 'Foundation', 'UIKit'

end