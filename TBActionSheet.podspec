Pod::Spec.new do |s|
s.name         = "TBActionSheet"
s.version      = "1.0.0"
s.summary      = "A Custom UIActionSheet"
s.description  = <<-DESC
If you want your UIAlertController to be compatible with iOS7(even lower), you can just replace your UIAlertController with TBAlertController
DESC
s.homepage     = "https://github.com/yulingtianxia/TBActionSheet"

s.license      = 'MIT'
s.author       = { "YangXiaoyu" => "yulingtianxia@gmail.com" }
s.social_media_url = "https://twitter.com/yulingtianxia"
s.source       = { :git => "https://github.com/yulingtianxia/TBActionSheet.git", :tag => s.version.to_s }

s.platform     = :ios, '6.0'
s.requires_arc = true

s.source_files = 'TBAlertController/*','TBActionSheet/*','Utils/*'
s.frameworks = 'Foundation', 'UIKit'

end