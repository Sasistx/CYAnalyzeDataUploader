//
//  CYUrlAnalyseListCell.h
//  ChunyuClinic
//
//  Created by 高天翔 on 16/9/8.
//  Copyright © 2016年 SpringRain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYUrlAnalyseManager.h"

@interface CYUrlAnalyseListCell : UITableViewCell

@property (nonatomic, strong) UILabel* urlLabel;
@property (nonatomic, strong) UILabel* methodLabel;
@property (nonatomic, strong) UILabel* statusLabel;

- (void)updateListInfo:(CYUrlAnalyseModel *)urlModel;

@end
