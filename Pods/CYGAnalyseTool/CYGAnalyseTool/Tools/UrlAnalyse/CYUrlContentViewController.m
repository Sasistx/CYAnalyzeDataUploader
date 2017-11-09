//
//  CYUrlContentViewController.m
//  CYGAnalyseTool
//
//  Created by 高天翔 on 2017/7/24.
//  Copyright © 2017年 CYGTX. All rights reserved.
//

#import "CYUrlContentViewController.h"
#import "CYUrlAnalyseManager.h"

@interface CYUrlContentViewController ()
@property (nonatomic, strong) UIScrollView* scrollView;
@end

@implementation CYUrlContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_scrollView];
    
    [self showContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showContent {

    UILabel* contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 30, self.view.frame.size.width - 100, 0)];
    contentLabel.numberOfLines = 0;
    contentLabel.text = _urlModel.responseContent ? : @"";
    [contentLabel sizeToFit];
    
    [_scrollView addSubview:contentLabel];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, contentLabel.frame.size.height + 60);
}

@end
