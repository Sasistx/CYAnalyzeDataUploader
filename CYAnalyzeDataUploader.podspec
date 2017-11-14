#
#  Be sure to run `pod spec lint CYAnalyzeDataUploader.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "CYAnalyzeDataUploader"
  s.version      = "1.0.0"
  s.summary      = "A uploader for CYGAnalyseTool's url analyze"
  s.description  = <<-DESC
                   DESC
  s.homepage     = "https://github.com/Sasistx/CYAnalyzeDataUploader"
  s.license      = "MIT"
  s.author       = { "gaotianxiang" => "gaotianxiang@chunyu.me" }
  s.source       = { :git => "https://github.com/Sasistx/CYAnalyzeDataUploader.git", :tag => s.version }
  s.source_files  =  "CYAnalyzeDataUploader/Classes/**/*.{h,m}"
  s.description  = "CYPhotoPicker is a uploader for CYGAnalyseTool's url analyze result or custom data."
  s.dependency 'CYGAnalyseTool', '~> 1.2'

end
