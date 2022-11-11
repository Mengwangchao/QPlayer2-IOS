//
//  PLCellPlayerViewController.m
//  PLPlayerKitDemo
//
//  Created by 冯文秀 on 2018/5/10.
//  Copyright © 2018年 Aaron. All rights reserved.
//

#import "PLCellPlayerViewController.h"
#import "PLCellPlayerTableViewCell.h"
#import "QNPlayerShortVideoMaskView.h"
#import "QNToastView.h"
static NSString *status[] = {
    @"Unknow",
    @"Preparing",
    @"Ready",
    @"Open",
    @"Caching",
    @"Playing",
    @"Paused",
    @"Stopped",
    @"Error",
    @"Reconnecting",
    @"Completed"
};
@interface PLCellPlayerViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
QIPlayerStateChangeListener,
QIPlayerProgressListener,
QIPlayerRenderListener,
QIMediaItemStateChangeListener,
QIMediaItemCommandNotAllowListener
>

@property (nonatomic, strong) QPlayerContext *player;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PLCellPlayerTableViewCell *currentCell;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, strong) NSMutableArray <QMediaItemContext *>*cacheArray;
@property (nonatomic, strong) NSMutableArray<QMediaModel *> *playerModels;

@property (nonatomic, assign) CGFloat topSpace;

@property (nonatomic, strong) QNToastView *toastView;
@property (nonatomic, strong) RenderView *myRenderView;

@end

@implementation PLCellPlayerViewController

- (void)dealloc {
    
    NSLog(@"PLCellPlayerViewController - dealloc");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.player.controlHandler stop];
    for (int i = 0; i < _cacheArray.count; i ++) {
        QMediaItemContext *item = _cacheArray[i];
       BOOL aa =  [item.controlHandler stop];
        NSLog(@"----%d",aa);
    }
    _toastView = nil;
    _currentCell = nil;
    [_playerModels removeAllObjects];
    [_cacheArray removeAllObjects];
    [self.player.controlHandler playerRelease];
    self.myRenderView = nil;
    self.player = nil;
    _playerModels = nil;
    _cacheArray = nil;
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
//    self.navigationController.navigationBar.barTintColor = PL_SEGMENT_BG_COLOR;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.cacheArray = [NSMutableArray array];
    // Do any additional setup after loading the view.

    self.title = @"短视频";
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance* appearance = [[UINavigationBarAppearance alloc]init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor =PL_SEGMENT_BG_COLOR;
        [self.navigationController.navigationBar setScrollEdgeAppearance:appearance];
        [self.navigationController.navigationBar setStandardAppearance:appearance];
        
    } else {
        self.navigationController.navigationBar.barTintColor = PL_SEGMENT_BG_COLOR;
        // Fallback on earlier versions
    };
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 6, 34, 34)];
    UIImage *image = [UIImage imageNamed:@"pl_back"];
    // iOS 11 之后， UIBarButtonItem 在 initWithCustomView 是图片按钮的情况下变形
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0f) {
        image = [self originImage:image scaleToSize:CGSizeMake(34, 34)];
    }
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(getBack) forControlEvents:UIControlEventTouchDown];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    

    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"lite_urls.json"];
    
    NSData *data=[[NSData alloc] initWithContentsOfFile:path];
    if (!data) {
        path=[[NSBundle mainBundle] pathForResource:@"lite_urls" ofType:@"json"];
        data=[[NSData alloc] initWithContentsOfFile:path];
    }
    NSArray *urlArray=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    _playerModels = [NSMutableArray array];
   
    for (NSDictionary *dic in urlArray) {

        QMediaModelBuilder *modleBuilder = [[QMediaModelBuilder alloc]initWithIsLive:[NSString stringWithFormat:@"%@",[dic valueForKey:@"isLive"]].intValue  == 0? NO : YES];
        for (NSDictionary *elDic in dic[@"streamElements"]) {
            [modleBuilder addStreamElementWithUserType:[NSString stringWithFormat:@"%@",[elDic valueForKey:@"userType"]]
                             urlType:[NSString stringWithFormat:@"%@",[elDic valueForKey:@"urlType"]].intValue
                             url:[NSString stringWithFormat:@"%@",[elDic valueForKey:@"url"]]
                             quality:[NSString stringWithFormat:@"%@",[elDic valueForKey:@"quality"]].intValue
                             isSelected:[NSString stringWithFormat:@"%@",[elDic valueForKey:@"isSelected"]].intValue == 0?NO : YES
                             backupUrl:[NSString stringWithFormat:@"%@",[elDic valueForKey:@"backupUrl"]]
                             referer:[NSString stringWithFormat:@"%@",[elDic valueForKey:@"referer"]]
                             renderType:[NSString stringWithFormat:@"%@",[elDic valueForKey:@"renderType"]].intValue];
        }
        QMediaModel *model = [modleBuilder build];
        [_playerModels addObject:model];
    }
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, PL_SCREEN_WIDTH, PL_SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = PLAYER_PORTRAIT_HEIGHT + 1;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.pagingEnabled = YES;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:_tableView];
    

    [self setUpPlayer];
    
    _toastView = [[QNToastView alloc]initWithFrame:CGRectMake(0, PL_SCREEN_HEIGHT - 350, 200, 300)];
    [self.view addSubview:_toastView];
    
    [self playerContextAllCallBack];
    
    
}

- (void)setUpPlayer{
    NSMutableArray *configs = [NSMutableArray array];
    if (PL_HAS_NOTCH) {
        _topSpace = 88;
    } else {
        _topSpace = 64;
    }
    
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *path = [documentsDir stringByAppendingPathComponent:@"me"];
    

    self.myRenderView = [[RenderView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    QPlayerContext *player = [[QPlayerContext alloc]initPlayerAPPVersion:@"" localStorageDir:documentsDir logLevel:LOG_VERBOSE];
    //设置为软解
//    [player.controlHandler setDecoderType:QPLAYER_DECODER_SETTING_SOFT_PRIORITY];
    self.player = player;
    [self.myRenderView attachPlayerContext:self.player];
    
    
    QMediaModel *model = _playerModels.firstObject;
    [self.player.controlHandler playMediaModel:model startPos:0];


}

#pragma mark - PLPlayerDelegate
-(void)playerContextAllCallBack{
    [self.player.controlHandler addPlayerStateListener:self];
    [self.player.controlHandler addPlayerProgressChangeListener:self];
    [self.player.renderHandler addPlayerRenderListener:self];

}
-(void)onStateChange:(QPlayerContext *)context state:(QPlayerState)state{
    if(state == QPLAYER_STATE_NONE){
        [_toastView addText:@"初始状态"];
        
    }
    else if (state ==     QPLAYER_STATE_INIT){
        
        [_toastView addText:@"创建完成"];
    }
    else if(state ==     QPLAYER_STATE_PREPARE ||state == QPLAYER_STATE_MEDIA_ITEM_PREPARE){
        [_toastView addText:@"正在加载"];
    }
    else if (state == QPLAYER_STATE_PLAYING) {
        if (_currentCell == nil) {
            [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        }else{
//            _currentCell.player = self.player;
        }
        _currentCell.state = YES;
        [_toastView addText:@"正在播放"];
    }
    else if(state == QPLAYER_STATE_PAUSED_RENDER){
        _currentCell.state = NO;
        [_toastView addText:@"播放暂停"];
    }
    else if(state == QPLAYER_STATE_STOPPED){
        _currentCell.state = NO;
        [_toastView addText:@"播放停止"];
    }
    else if(state == QPLAYER_STATE_COMPLETED){
        _currentCell.state = NO;
        [self.player.controlHandler seek:0];
        [_toastView addText:@"播放完成"];
    }
    else if(state == QPLAYER_STATE_ERROR){
        _currentCell.state = NO;
        
        [_toastView addText:@"播放出错"];
    }
    else if (state == QPLAYER_STATE_SEEKING){
        [_toastView addText:@"正在seek"];
    }
    else{
        [_toastView addText:@"其他状态"];
    }

}

-(void)onFirstFrameRendered:(QPlayerContext *)context elapsedTime:(NSInteger)elapsedTime{
    NSLog(@"预加载首帧时间----%d",elapsedTime);

    dispatch_async(dispatch_get_main_queue(), ^{
        _currentCell.playerView = _myRenderView;
        
    });
}


#pragma mark - mediaItemDelegate

-(void)addAllCallBack:(QMediaItemContext *)mediaItem{
    [mediaItem.controlHandler addMediaItemStateChangeListener:self];
    [mediaItem.controlHandler addMediaItemCommandNotAllowListener:self];


}
-(void)onStateChanged:(QMediaItemContext *)context state:(QMediaItemState)state{
    NSLog(@"-------------预加载--onStateChanged -- %d---%@",state,context.controlHandler.mediaModel.streamElements[0].url);
}
-(void)onCommandNotAllow:(QMediaItemContext *)context commandName:(NSString *)commandName state:(QMediaItemState)state{
    NSLog(@"-------------预加载--notAllow---%@",commandName);
}
#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _playerModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section], (long)[indexPath row]];
    // 出列可重用的 cell，从缓存池取标识为 "Cell" 的 cell
    PLCellPlayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PLCellPlayerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    QMediaModel *model = _playerModels[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PLCellPlayerTableViewCell *cell = (PLCellPlayerTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self updatePlayCell:cell scroll:NO];

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return PL_SCREEN_HEIGHT;
}


// 松手时已经静止,只会调用scrollViewDidEndDragging
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO) { // scrollView已经完全静止
        [self handleScroll];
    }
}

// 松手时还在运动, 先调用scrollViewDidEndDragging,在调用scrollViewDidEndDecelerating
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // scrollView已经完全静止
    [self handleScroll];
}

-(void)handleScroll{
    // 找到下一个要播放的cell(最在屏幕中心的)
    
    PLCellPlayerTableViewCell *finnalCell = nil;
    NSArray *visiableCells = [self.tableView visibleCells];
    CGFloat gap = MAXFLOAT;
    for (PLCellPlayerTableViewCell *cell in visiableCells) {

        if (cell.model) { // 如果这个cell有视频
            CGPoint coorCentre = [cell.superview convertPoint:cell.center toView:nil];
            CGFloat delta = fabs(coorCentre.y-[UIScreen mainScreen].bounds.size.height*0.5);
            if (delta < gap) {
                gap = delta;
                finnalCell = cell;
            }
        }
    }

    
    // 注意, 如果正在播放的cell和finnalCell是同一个cell, 不应该在播放
    if (finnalCell != nil && _currentCell != finnalCell)  {
        
        [self updateForAddCache:finnalCell.model];
        
        [self updatePlayCell:finnalCell scroll:YES];
        
        [self updateForDeleteCache:finnalCell.model];
        return;
    }
    
//    [self updatePlayCell:finnalCell scroll:YES];
}


-(void)updatePlayCell:(PLCellPlayerTableViewCell *)cell scroll:(BOOL)scroll{
    cell.player = self.player;
    
    BOOL isPlaying = (_player.controlHandler.currentPlayerState == QPLAYER_STATE_PLAYING);
    
    if (_currentCell == cell && _currentCell) {
        if (!scroll) {
            if(isPlaying) {
                    [_player.controlHandler pauseRender];
            } else{
                    [_player.controlHandler resumeRender];
            }
        }
    } else{
//        NSLog(@"url is :  ------%@-----",cell.model.streamElements[0].url);
        QMediaItemContext *item = [self findCrashMediaItemsOf:cell.model];
        if (item) {
            BOOL playBool = [self.player.controlHandler playMediaItem:item];
            [self.cacheArray removeObject:item];
            if (!playBool) {
                NSLog(@"播放错误");
            }
            NSLog(@"预加载--播放缓存---%@",item.controlHandler.mediaModel.streamElements[0].url);
            
        }else if(_currentCell != nil){
            QMediaModelBuilder *modelBuilder = [[QMediaModelBuilder alloc] initWithIsLive:_playerModels.firstObject.isLive];
            [modelBuilder addStreamElements:cell.model.streamElements];
            QMediaModel *model = [modelBuilder build];
            BOOL playBool = [self.player.controlHandler playMediaModel:model startPos:0];
            if (!playBool) {
                NSLog(@"播放错误");
            }
            NSLog(@"预加载--new---%@",item.controlHandler.mediaModel.streamElements[0].url);
        }
    
        _currentCell = cell;
    }

}


-(void)AddToCash:(QMediaModel *)playerModel{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *path = [documentsDir stringByAppendingPathComponent:@"me"];
    
    
    QMediaModel *model = playerModel;
    // 预加载
    QMediaItemContext *item = [[QMediaItemContext alloc]initItemComtextWithMediaModel:model startPos:0 storageDir:documentsDir logLevel:LOG_VERBOSE];
    [self addAllCallBack:item];
    [item.controlHandler start];
    [self.cacheArray addObject:item];
    
    NSLog(@"预加载--addcrash -- %@",playerModel.streamElements.firstObject.url);
    
}

-(int)indexPlayerModelsOf:(QMediaItemContext *)item{
    for (int i = 0; i < _playerModels.count; i ++) {
        QMediaModel *modle = _playerModels[i];
        if (modle.isLive == item.controlHandler.mediaModel.isLive && modle.streamElements == item.controlHandler.mediaModel.streamElements) {
            return i;
        }
    }
    return -1;
}

-(QMediaItemContext *)findCrashMediaItemsOf:(QMediaModel *)modle{
    for (int i = 0; i < _cacheArray.count; i ++) {
        QMediaItemContext *item = _cacheArray[i];
        if (modle.isLive == item.controlHandler.mediaModel.isLive && modle.streamElements == item.controlHandler.mediaModel.streamElements) {
            return item;
        }
    }
    return NULL;
}
-(void)updateForAddCache:(QMediaModel *)model{
    
    NSArray *realCacheArray = [self getRealCacheIndexArray:model];
    for (int i = 0; i < realCacheArray.count; i ++) {//
        int index = [realCacheArray[i] intValue];
        QMediaModel *model0 = _playerModels[index];
        if (![self findCrashMediaItemsOf:model0]) {// realCacheArray 独有
            [self AddToCash:_playerModels[index]];
        }
    }
    
}

-(void)updateForDeleteCache:(QMediaModel *)model{

    NSArray *realCacheArray = [self getRealCacheIndexArray:model];
    
    NSMutableArray *delArray = [NSMutableArray array];

    for (int i = 0; i < _cacheArray.count; i ++) {//
        QMediaItemContext *model0 = _cacheArray[i];
        int index = (int)[self indexPlayerModelsOf:model0];
        if (![realCacheArray containsObject:@(index)]) {// _cacheArray 独有
            [delArray addObject:model0];
            [model0.controlHandler stop];

        }
    }

//    for (int i = 0; i < realCacheArray.count; i ++) {//
//        int index = [realCacheArray[i] intValue];
//        QMediaModel *model0 = _playerModels[index];
//        if (![self findCrashMediaItemsOf:model0]) {// realCacheArray 独有
//            [self AddToCash:_playerModels[index]];
//        }
//    }
    [_cacheArray removeObjectsInArray:delArray];
    [delArray removeAllObjects];
    delArray = nil;
}

// 前 1 后 3
-(NSArray *)getRealCacheIndexArray:(QMediaModel *)model{
    NSArray *realCacheArray = nil;
    if (_playerModels.count <= 5) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < _playerModels.count; i ++) {
            [array addObject:@(i)];
        }
        realCacheArray = [array copy];
        return realCacheArray;
    }

    int index = (int)[_playerModels indexOfObject:model];
    if (index == 0) {
        realCacheArray = @[@0,@1,@2,@3];
    }

    if (index == _playerModels.count-1) {
        realCacheArray = @[@(index-1),@(index)];
    }
    if (index == _playerModels.count-2) {
        realCacheArray = @[@(index-1),@(index),@(index + 1)];
    }
    if (index == _playerModels.count-3) {
        realCacheArray = @[@(index-1),@(index),@(index + 1),@(index + 2)];
    }
    
    if (realCacheArray.count == 0) {//之前没有命中
        realCacheArray = @[@(index -1),@(index),@(index + 1),@(index + 2),@(index + 3)];
    }
    
    return realCacheArray;
}


- (void)getBack {
    [self.player.controlHandler stop];
    [self.navigationController popViewControllerAnimated:YES];
}




- (UIImage *)originImage:(UIImage *)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
