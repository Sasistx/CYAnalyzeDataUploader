# CYAnalyzeDataUploader
CYUrlAnalyse 结果上传工具/自定义数据上传至bomb工具

##使用方法：
objc

[[CYAnalyzeUploader sharedInstance] startUrlAutoUpload];
开启自动上传

- (void)uploadDataList:(NSArray *)dataList path:(NSString *)path success:(CYAnalyzeUploaderSuccess)success failed:(CYAnalyzeUploaderFailed)failed
自定义上传
