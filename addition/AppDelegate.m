//
//  AppDelegate.m
//  addition
//
//  Created by 최준호 on 11. 12. 14..
//  Copyright (c) 2011년 SPARROWAPPS. All rights reserved.
// 카울리 G4fri7I9

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
#ifdef FREE_APP
    // 지역 체크!
    NSString   *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    NSLog(@"The device's specified countryCode is %@", countryCode);
    
    // embed AD
    _isBannerVisible = NO;
    
    if ([countryCode isEqualToString:@"KR"]) {
        [self AddCaulyAD];
    } else {
        //[self AddiAd];
    }
#endif   
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - CaulyAD
#ifdef FREE_APP
- (void)AddCaulyAD {
    [CaulyViewController initCauly:self];
    
    float yPos = self.viewController.view.frame.size.height - 48;
    
    if( [CaulyViewController requestBannerADWithViewController:_viewController xPos:0 yPos:yPos adType:BT_IPHONE] == FALSE ) {
        NSLog(@"requestBannerAD failed");
    }
}

- (void)AdReceiveCompleted {
    NSLog(@"CaulyAD AdReceiveCompleted..");
    
    if (!_isBannerVisible) {
        [UIView beginAnimations:@"animateAdBannerOn" context:nil];
        [CaulyViewController moveBannerAD:self.viewController caulyParentview:nil xPos:0 yPos:self.viewController.view.frame.size.height - 48];
        [UIView commitAnimations];
        _isBannerVisible = YES;
    }
}

- (void)AdReceiveFailed {
    NSLog(@"CaulyAD AdReceiveFailed..");
    
    if (_isBannerVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:nil];
        [CaulyViewController moveBannerAD:self.viewController caulyParentview:nil xPos:0 yPos:self.viewController.view.frame.size.height];
        [UIView commitAnimations];
        _isBannerVisible = NO;
    }
}

- (NSString *) devKey {
    return @"G4fri7I9";
}

- (NSString *) gender {
    return @"all";
}

- (NSString *) age {
    return @"all";
}

- (BOOL) getGPSInfo {
    return FALSE;
}

- (REFRESH_PERIOD) rollingPeriod {
    return SEC_60;
}

- (ANIMATION_TYPE) animationType {
    return FADEOUT;
}
#endif

@end
