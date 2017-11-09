//
//  CYUrlAnalyseListViewController.m
//  ChunyuClinic
//
//  Created by 高天翔 on 16/9/8.
//  Copyright © 2016年 SpringRain. All rights reserved.
//

#import "CYUrlAnalyseListViewController.h"
#import "CYUrlAnalyseManager.h"
#import "CYUrlAnalyseListCell.h"
#import "CYUrlAnalyzeDetailViewController.h"
#import "CYUrlBaseViewController.h"

@interface CYUrlAnalyseListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;

@end

@implementation CYUrlAnalyseListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Analyse List";
    
    UIBarButtonItem* leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeCurrentView:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    if ([CYUrlAnalyseManager defaultManager].isEnableUrlAnalyse) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
        [self.view addSubview:_tableView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlAnalyseChanged:) name:CYUrlAnalyseChangeKey object:nil];
    }
    
    if ([CYUrlAnalyseManager defaultManager].isEnableOverlay) {
        
        UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:@"more" style:UIBarButtonItemStylePlain target:self action:@selector(moreItem:)];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)moreItem:(id)sender {

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    @weakify(self);
    UIAlertAction* overlayAction = [UIAlertAction actionWithTitle:@"overlay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        @strongify(self);
        [self.presentingViewController dismissViewControllerAnimated:YES completion:Nil];
        [[CYUrlAnalyseManager defaultManager] cleanUrlController];
#ifdef DEBUG
        id informationOverlay = NSClassFromString(@"UIDebuggingInformationOverlay");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [informationOverlay performSelector:@selector(prepareDebuggingOverlay)];
        [[informationOverlay performSelector:@selector(overlay)] performSelector:@selector(toggleVisibility)];
#pragma clang diagnostic pop
#endif
    }];
    [alert addAction:overlayAction];
    
    if ([CYUrlAnalyseManager defaultManager].storageType == CYUrlStorageTypeAutoDB) {
        
        
    } else {
        
        UIAlertAction* plistAction = [UIAlertAction actionWithTitle:@"url plist 归档" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[CYUrlAnalyseManager defaultManager] writeUrlDataToPlistWithfinishBlock:^(BOOL success) {
                
                @strongify(self);
                
                NSString* title = success ? @"归档成功" : @"url归档失败";
                
                UIAlertController* doneController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:Nil];
                [doneController addAction:doneAction];
                [self presentViewController:doneController animated:YES completion:Nil];
            }];
        }];
        [alert addAction:plistAction];
        
        UIAlertAction* dbAction = [UIAlertAction actionWithTitle:@"url db 归档" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[CYUrlAnalyseManager defaultManager] writeDataToDB];
        }];
        [alert addAction:dbAction];
    }
    
    UIAlertAction* cleanAction = [UIAlertAction actionWithTitle:@"清除列表" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
       
        [[CYUrlAnalyseManager defaultManager] cleanAllObejct];
    }];
    [alert addAction:cleanAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
    }];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:Nil];
}

- (void)closeCurrentView:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:Nil];
    [[CYUrlAnalyseManager defaultManager] cleanUrlController];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[CYUrlAnalyseManager defaultManager].urlArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellId = @"cellId";
    CYUrlAnalyseListCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        
        cell = [[CYUrlAnalyseListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    CYUrlAnalyseModel* urlModel = [CYUrlAnalyseManager defaultManager].urlArray[indexPath.row];
    [cell updateListInfo:urlModel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CYUrlBaseViewController* controller = [[CYUrlBaseViewController alloc] init];
    controller.urlModel = [CYUrlAnalyseManager defaultManager].urlArray[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)urlAnalyseChanged:(NSNotification*)note
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [_tableView reloadData];
    });
}

@end
