//
//  qplayer2demoUITests.m
//  qplayer2demoUITests
//
//  Created by Dynasty Dream on 2023/10/11.
//

#import <XCTest/XCTest.h>
#import <XCTest/XCUIElement.h>
@interface qplayer2demoUITests : XCTestCase
@property (nonatomic, assign) int flag;
@property (nonatomic, strong) XCUIApplication *app;

@end

@implementation qplayer2demoUITests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // UI tests must launch the application that they test.
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testLaunchPerformance {
    if (@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *)) {
        // This measures how long it takes to launch your application.
        [self measureWithMetrics:@[[[XCTApplicationLaunchMetric alloc] init]] block:^{
            [[[XCUIApplication alloc] init] launch];
        }];
    }
}
- (void)testLongVideo{
    self.app = [[XCUIApplication alloc] init];
    [self.app launch];
    XCUIElement *button = self.app.buttons[@"longVideoButton"]; // 使用按钮的标识符来获取按钮元素
    // 判断按钮是否存在并可点击
    if (button.exists && button.isHittable) {
        // 点击按钮
        [button tap];
    } else {
        // 如果按钮不存在或不可点击，打印错误信息
        NSLog(@"按钮不存在或不可点击");
    }
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Gesture expectation"];
    // 启动定时器
    self.flag = 0 ;

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(testLongVideo:) userInfo:expectation repeats:YES];
    
    // 等待期望对象被满足，最多等待 10 秒
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:1000000.0];
    
    // 验证手势操作是否成功完成
    XCTAssertEqual(result, XCTWaiterResultCompleted, @"Gesture execution failed to complete within the timeout.");
    [timer invalidate];
}
-(void)testLongVideo:(NSTimer *)timer{
    XCTestExpectation *expectation = (XCTestExpectation *)timer.userInfo;
    // 上划手势
    if(self.flag %40 == 0){
        XCUIElement *backButton = self.app.buttons[@"longVideoBack"]; // 使用按钮的标识符来获取按钮元素

        // 判断按钮是否存在并可点击
        if (backButton.exists && backButton.isHittable) {
            // 点击按钮
            [backButton tap];
            sleep(1);
            XCUIElement *button = self.app.buttons[@"longVideoButton"]; //
            if (button.exists && button.isHittable) {
                // 点击按钮
                [button tap];
            } else {
                // 如果按钮不存在或不可点击，打印错误信息
                NSLog(@"按钮不存在或不可点击");
            }
        } else {
            // 如果按钮不存在或不可点击，打印错误信息
            NSLog(@"按钮不存在或不可点击");
        }
    }else{
        XCUIElement *backButton = self.app.cells[@"urlCell 1"]; // 使用按钮的标识符来获取按钮元素
        if (backButton.exists && backButton.isHittable) {
            // 点击按钮
            [backButton tap];
        } else {
            // 如果按钮不存在或不可点击，打印错误信息
            NSLog(@"按钮不存在或不可点击");
        }
    }

    
    if(self.flag == 2000){
        [expectation fulfill];
    }
    self.flag ++;
    NSLog(@"----------flag num = %d------",self.flag);
}
- (void)testShortVideo {
    self.app = [[XCUIApplication alloc] init];
    [self.app launch];
    // 获取按钮元素
    XCUIElement *button = self.app.buttons[@"shortVideoButton"]; // 使用按钮的标识符来获取按钮元素
    
    // 判断按钮是否存在并可点击
    if (button.exists && button.isHittable) {
        // 点击按钮
        [button tap];
    } else {
        // 如果按钮不存在或不可点击，打印错误信息
        NSLog(@"按钮不存在或不可点击");
    }
    // 创建一个期望对象，用于等待手势操作完成
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Gesture expectation"];
    
    // 启动定时器
    self.flag = 0 ;

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(testSwipeGesture:) userInfo:expectation repeats:YES];
    
    // 等待期望对象被满足，最多等待 10 秒
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[expectation] timeout:1000000.0];
    
    // 验证手势操作是否成功完成
    XCTAssertEqual(result, XCTWaiterResultCompleted, @"Gesture execution failed to complete within the timeout.");
    [timer invalidate];
}
-(void)testSwipeGesture:(NSTimer *)timer{
    
    XCTestExpectation *expectation = (XCTestExpectation *)timer.userInfo;
    XCUIElement *element = self.app.otherElements[@"shortViewController"];

    // 上划手势
    if(self.flag %40 == 0){
        XCUIElement *backButton = self.app.buttons[@"shortViewController back"]; // 使用按钮的标识符来获取按钮元素

        // 判断按钮是否存在并可点击
        if (backButton.exists && backButton.isHittable) {
            // 点击按钮
            [backButton tap];
            XCUIElement *button = self.app.buttons[@"shortVideoButton"]; //
            if (button.exists && button.isHittable) {
                // 点击按钮
                [button tap];
            } else {
                // 如果按钮不存在或不可点击，打印错误信息
                NSLog(@"按钮不存在或不可点击");
            }
        } else {
            // 如果按钮不存在或不可点击，打印错误信息
            NSLog(@"按钮不存在或不可点击");
        }
    }
    else if(self.flag%6 <3){
//    if(self.flag%6 <3){
        XCUICoordinate *startCoordinate = [element coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.55)];
        XCUICoordinate *endCoordinate = [element coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.45)];
        [startCoordinate pressForDuration:0.01 thenDragToCoordinate:endCoordinate];

    }else{

        XCUICoordinate *startCoordinate = [element coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.45)];
        XCUICoordinate *endCoordinate = [element coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.55)];
        [startCoordinate pressForDuration:0.01 thenDragToCoordinate:endCoordinate];

    }
    if(self.flag == 2000){
        [expectation fulfill];
    }
    self.flag ++;
    NSLog(@"----------flag num = %d------",self.flag);
}


@end
