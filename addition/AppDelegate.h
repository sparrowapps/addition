//
//  AppDelegate.h
//  addition
//
//  Created by 최준호 on 11. 12. 14..
//  Copyright (c) 2011년 SPARROWAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef FREE_APP
#import "CaulyViewController.h"
#endif

@class ViewController;

#ifdef FREE_APP
@interface AppDelegate : UIResponder <UIApplicationDelegate, CaulyProtocol>
#else
@interface AppDelegate : UIResponder <UIApplicationDelegate>
#endif
{
#ifdef FREE_APP
    BOOL _isBannerVisible;
#endif
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

#ifdef FREE_APP
- (void) AddCaulyAD;
#endif

@end
