//
//  ViewController.m
//  CYAnalyzeDataUploader
//
//  Created by 高天翔 on 2017/11/8.
//  Copyright © 2017年 chunyu. All rights reserved.
//

#import "ViewController.h"
#import "CYUrlAnalyseListViewController.h"
#import "CYAnalyzeUploader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    [webView loadRequest:request];
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:@"network" style:UIBarButtonItemStylePlain target:self action:@selector(openAnalyse:)];
    self.navigationItem.leftBarButtonItem = rightItem;
    
    [[CYAnalyzeUploader sharedInstance] startUrlAutoUpload];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openAnalyse:(id)sender {
    
    CYUrlAnalyseListViewController* controller = [[CYUrlAnalyseListViewController alloc] init];
    UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:controller];
    UIViewController* currentController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [currentController presentViewController:navi animated:YES completion:Nil];
    
    //[[CYUrlAnalyseManager defaultManager] registAnalyse];
}

@end
