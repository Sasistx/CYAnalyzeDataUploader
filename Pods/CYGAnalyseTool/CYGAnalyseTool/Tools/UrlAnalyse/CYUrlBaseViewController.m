//
//  CYUrlBaseViewController.m
//  CYGAnalyseTool
//
//  Created by 高天翔 on 2017/7/24.
//  Copyright © 2017年 CYGTX. All rights reserved.
//

#import "CYUrlBaseViewController.h"
#import "CYUrlAnalyzeDetailViewController.h"
#import "CYUrlContentViewController.h"
#import "CYUrlAnalyseManager.h"

@interface CYUrlBaseViewController ()
@property (nonatomic, strong) NSMutableArray* segControllers;
@end

@implementation CYUrlBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UISegmentedControl* segment = [[UISegmentedControl alloc] initWithItems:@[@"request", @"content"]];
    [segment addTarget:self action:@selector(segmentDidChanged:) forControlEvents:UIControlEventValueChanged];
    segment.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segment;
    
    _segControllers = [NSMutableArray array];
    CYUrlAnalyzeDetailViewController* detailController = [[CYUrlAnalyzeDetailViewController alloc] init];
    detailController.urlModel = _urlModel;
    [self.view addSubview:detailController.view];
    [self addChildViewController:detailController];
    [_segControllers addObject:detailController];
    
    CYUrlContentViewController* contentController = [[CYUrlContentViewController alloc] init];
    contentController.urlModel = _urlModel;
    [self.view addSubview:contentController.view];
    [self addChildViewController:contentController];
    [_segControllers addObject:contentController];
    
    [self.view bringSubviewToFront:detailController.view];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"Copy" style:UIBarButtonItemStylePlain target:self action:@selector(copyButtonClicked:)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

    
}

- (void)segmentDidChanged:(UISegmentedControl *)segment {

    NSInteger selectedIndex = segment.selectedSegmentIndex;
    UIViewController* controller = nil;
    controller = _segControllers[selectedIndex];
    [self.view bringSubviewToFront:controller.view];
}

- (void)copyButtonClicked:(id)sender
{
    __block NSString* urlString = _urlModel.requestUrl;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"Select" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action) {
                                                        
                                                    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"request url"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        
                                                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                                        [pasteboard setString:urlString];
                                                    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [self.navigationController presentViewController:alertController animated:YES completion:Nil];
}

@end
