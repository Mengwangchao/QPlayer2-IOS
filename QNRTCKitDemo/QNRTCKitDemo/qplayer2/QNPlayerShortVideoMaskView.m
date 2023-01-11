//
//  QNPlayerShortVideoMaskView.m
//  QPlayerKitDemo
//
//  Created by 王声禄 on 2022/7/25.
//  Copyright © 2022 Aaron. All rights reserved.
//

#import "QNPlayerShortVideoMaskView.h"
#import "QNButtonView.h"
@interface QNPlayerShortVideoMaskView()

@property (nonatomic, strong) QNButtonView *buttomView;

@end

@implementation QNPlayerShortVideoMaskView

-(instancetype)initWithShortVideoFrame:(CGRect)frame player:(QPlayerContext *)player isLiving:(BOOL)isLiving{
    self = [super initWithFrame:frame];
    if (self) {
        self.player = player;
        self.isLiving = isLiving;

        CGFloat playerWidth = CGRectGetWidth(frame);
        CGFloat playerHeight = CGRectGetHeight(frame);
        
        self.buttomView = [[QNButtonView alloc]initWithShortVideoFrame:CGRectMake(8, playerHeight - 28, playerWidth - 16, 28) player:player playerFrame:frame isLiving:isLiving];
        [self addSubview:_buttomView];
        __weak typeof(self) weakSelf = self;
        [self.buttomView playButtonClickCallBack:^(BOOL selectedState) {
            if(weakSelf.player.controlHandler.currentPlayerState == QPLAYER_STATE_COMPLETED){
                if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(reOpenPlayPlayerMaskView:)]) {
                    [weakSelf.delegate reOpenPlayPlayerMaskView:weakSelf];
                }
            }
        }];
        
    }
    return  self;
}

#pragma mark - public methods
-(void)setPlayButtonState:(BOOL)state{
    [self.buttomView setPlayButtonState:state];
}
-(void)setPlayer:(QPlayerContext *)player{
    _player = player;
    if (self.buttomView) {
        self.buttomView.player = player;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
