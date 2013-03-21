//
//  ViewController.h
//  addition
//
//  Created by 최준호 on 11. 12. 14..
//  Copyright (c) 2011년 SPARROWAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPSoundEffect.h"
#import "SPGameKitUtil.h"

#ifdef FREE_APP
#import <iAd/iAd.h>
#import "CaulyViewController.h"
#endif

typedef enum game_sound_id_type {
    SND_MOVE,
    SND_BOMB,
    SND_SHAKE,
    SND_GET_BONUS,
    SND_MISS,
    SND_MAX,
}game_sound_id_type;

#define BTN_SIZE_X 57
#define BTN_SIZE_Y 57
#define SPACING_X  5
#define SPACING_Y  5
#define FIRST_BUTTON_Y 100
#define FIRST_BUTTON_X 7

#define ITEM_COUNT_MAX 5

#define ANIMATION_DURATION (0.7)

#define EMPTY_BUTTON (0)

typedef enum game_item_type {
    ITEM_NONE,
    ITEM_SCORE,
    ITEM_HINT,
    ITEM_BOMB,
    ITEM_TIME,
    ITEM_MAX,
}game_item_type;

#ifdef FREE_APP
@interface ViewController : UIViewController <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, UIActionSheetDelegate, ADBannerViewDelegate> 
#else
@interface ViewController : UIViewController <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, UIActionSheetDelegate>
#endif
{
    IBOutlet UILabel *mlblScore;
    IBOutlet UILabel *mlblLevel;
    IBOutlet UILabel *mlblTime;
    IBOutlet UILabel *mlblNumber;
    IBOutlet UILabel *mlblNumber2;
    IBOutlet UIButton *mbtnHint;
    IBOutlet UILabel *mlblHint;
    IBOutlet UIButton *mbtnBomb;
    IBOutlet UILabel *mlblBomb;
    IBOutlet UIButton *mbtnMenu;
    
    UILabel * mlblMsg;
    
    SPSoundEffect * mMoveSound;
    SPSoundEffect * mBombSound;
    SPSoundEffect * mShakeSound;
    SPSoundEffect * mMissSound;
    SPSoundEffect * mBonusSound;
    
    NSTimer * mTimer;
    
#ifdef FREE_APP
    BOOL _isBannerVisible;
    ADBannerView * adBanner;
#endif
}

//#pragma mark IBAction
- (IBAction)hintBtnClick:(id)sender;
- (IBAction)bombBtnClick:(id)sender;
- (IBAction)menuBtnClick:(id)sender;

//#pragma mark - UI Componenet
- (void) initGameScreen;
- (void) newGame;
- (void) btnClick:(id)sender;
- (void) makeBtnImage:(UIButton *)btn;
- (void) panalty;
- (void) hideBtn: (UIButton *)btn;
- (void) unselectBtnAll;

//#pragma mark - Calculate
- (int) randomRange:(int)minvalue max:(int)maxvalue;
- (int) getNumber;
- (BOOL) checkGameComplete;
- (void) doCorrect:(UIButton *)btn;
- (void) checkItem:(UIButton *)btn;

//#pragma mark - Timer
- (void) startTimer;
- (void) handleTimer:(NSTimer*)timer;

//#pragma mark - Label display
- (void) displayNumber; //정답
- (void) displayNumber2; //풀고잇는답
- (void) displayScore;
- (void) displayLevel;
- (void) displayHint;
- (void) displayBomb;

- (void) displaySecond;
- (void) displayMsg:(NSString *)msg withX:(int)x andY:(int)y;
- (void) displayGameOver;

//#pragma mark - Sound Componenet
- (void) initSound;
- (void) releaseSound;
- (void) soundPlay:(game_sound_id_type)snd_id;

//#pragma mark - leaderboard    
- (void) showLeaderboard;
- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController ;
- (void) showArchboard;
- (void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;

//#progma mark - iAD, Cauly
#ifdef FREE_APP
- (void) adBannerInit;
- (void) AddCaulyAD;
#endif

@end
