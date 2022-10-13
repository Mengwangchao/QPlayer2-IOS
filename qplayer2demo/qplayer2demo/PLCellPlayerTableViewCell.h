//
//  PLCellPlayerTableViewCell.h
//  PLPlayerKitCellDemo
//
//  Created by 冯文秀 on 2018/3/12.
//  Copyright © 2018年 Hera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLCellPlayerTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *url;
@property (nonatomic, weak) QPlayerContext *player;
@property (nonatomic, strong) UILabel *URLLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, assign) BOOL state;
@property (nonatomic, weak) RenderView *playerView;
@property (nonatomic, weak) QMediaModel *model;



@end
