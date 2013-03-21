//
//  ViewController.m
//  addition
//
//  Created by 최준호 on 11. 12. 14..
//  Copyright (c) 2011년 SPARROWAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"

@implementation ViewController

static NSMutableArray * btnArray = nil;

static int levelStartIdx[10]={1,1,1,1,1,1,1,1,1,1};
static int levelEndIdx[10]={30,40,50,60,70,80,90,100,110,120};

static int gLevel = 0;
static int gScore;
static int gSecond = 180;
static int gRemainButtons;
static int gHintCount = 3;
static int gBombCount = 3;

//xy 값이 변경되는 것 때문에 보관
static int gBtnOrignX[25];
static int gBtnOrignY[25];

//현재 플레그 index
static int gNumber;
static int gNumber2; //사용자 계산 번호

//선택번호 button index array
static NSMutableArray * selectBtnArray = nil;

static int numberArray[25];
static game_item_type itemArray[25];

static int gSelectNumbers[4];
static int gSelectNumberCount;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    btnArray = [[NSMutableArray alloc]init];
    
    selectBtnArray = [[NSMutableArray alloc]init];
    
    [self initGameScreen];
    [self initSound];
    [self newGame]; //<--- startPoint
    [self startTimer];
    
    if ([SPGameKitUtil isGameCenterAvailable]) { //게임센터가 가능한 단말이면...
        [SPGameKitUtil connectGameCenter];       //게임센터 접속~
    }
    
#ifdef FREE_APP
    // 지역 체크!
    NSString   *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    NSLog(@"The device's specified countryCode is %@", countryCode);
    _isBannerVisible = NO;
    
    if ([countryCode isEqualToString:@"KR"]) {
        [self AddCaulyAD];
    } else {
        [self adBannerInit];
    }
#endif    

}

- (void)dealloc
{
    if(btnArray != nil)
    {
        for (int i=0;i<25;i++)
        {
            UIButton * btn = [btnArray objectAtIndex:i];
            [btn removeFromSuperview];
        }
    }
        
    [btnArray release];
    btnArray = nil;
    
    [selectBtnArray release];
    selectBtnArray = nil;
    
    [mlblMsg removeFromSuperview];
    
    [mlblScore release];
    [mlblLevel release];
    [mlblTime release];
    
    [mlblMsg release];
    [mlblNumber release];
    [mlblNumber2 release];
    
    [self releaseSound];
    
    [mbtnHint release];
    [mlblHint release];
    [mbtnBomb release];
    [mlblBomb release];
    [mbtnMenu release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [mlblScore release];
    mlblScore = nil;
    [mlblLevel release];
    mlblLevel = nil;
    [mlblTime release];
    mlblTime = nil;
    [mlblNumber release];
    mlblNumber = nil;
    [mlblNumber2 release];
    mlblNumber2 = nil;
    
    [mlblMsg release];
    mlblMsg = nil;
    
    [mTimer invalidate];
    mTimer = nil;
    
    [mbtnHint release];
    mbtnHint = nil;
    [mlblHint release];
    mlblHint = nil;
    [mbtnBomb release];
    mbtnBomb = nil;
    [mlblBomb release];
    mlblBomb = nil;
    [mbtnMenu release];
    mbtnMenu = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - UI Componenet
- (void)initGameScreen
{
    int tag = 0 ;
    
    srand(time(NULL));
    
    //버튼 25개 
    for (int i=0; i<5; i++)
    {
        for (int j=0; j<5; j++)
        {
            UIButton * btn = [[UIButton alloc]init];
            
            btn.frame = CGRectMake(FIRST_BUTTON_X + (j*BTN_SIZE_X+j*SPACING_X), FIRST_BUTTON_Y +(i*BTN_SIZE_Y+i*SPACING_Y), BTN_SIZE_X, BTN_SIZE_Y);
            
            [[btn layer] setCornerRadius:8.0f];
            [[btn layer] setMasksToBounds:YES];
            [[btn layer] setBorderWidth:1.0f];
            [btn setBackgroundColor:[UIColor blackColor]];
            
            [btn setTag:tag ++];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
            [self.view addSubview:btn];
            
            //xy 보관
            gBtnOrignX[btn.tag] = btn.frame.origin.x;
            gBtnOrignY[btn.tag] = btn.frame.origin.y;
            
            [btnArray addObject:btn];
            [btn release];
        }
    }
    
    //아이템 , 점수 획득용 lbl
    mlblMsg = [[UILabel alloc]init];
    mlblMsg.frame = CGRectMake(160, 240, 100, 20);
    mlblMsg.textAlignment = UITextAlignmentCenter;
    mlblMsg.backgroundColor = [UIColor clearColor];
    mlblMsg.textColor = [UIColor whiteColor];
    [self.view addSubview:mlblMsg];
}

- (void) newGame
{
    gRemainButtons = 25;

    for (int i=0; i<25; i++)
    {
        [self makeBtnImage:[btnArray objectAtIndex:i]];
        itemArray[i] = ITEM_NONE;
    }
    
    //item 숨겨두기
    for (int i=0; i<ITEM_COUNT_MAX; i++)
    {
        int idx = [self randomRange:0 max:24];
        int itm = [self randomRange:0 max:ITEM_MAX];
        itemArray[idx] = itm;
    }
    
    [selectBtnArray removeAllObjects];
    
    for (int i=0; i<4; i++)
    {
        gSelectNumbers[i] = 0;
    }
    gSelectNumberCount = 0;
    
    
    [self displaySecond];
    [self startTimer];
    
    gNumber = [self getNumber];
    [self displayNumber];
    
    gNumber2 = 0;
    [self displayNumber2];
    
    //score
    [self displayScore];
    
    //level
    [self displayLevel];
    
    //hint,
    [self displayHint];
    
    //bomb
    [self displayBomb];
}

//버튼 클릭 
- (void) btnClick:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    
    if (btn.selected == YES)
    {
        btn.selected = NO;
        [btn setBackgroundColor:[UIColor blackColor]];
    }
    else
    {
        [btn setBackgroundColor:[UIColor grayColor]];
        btn.selected = YES;
    }

    if (btn.selected == YES)
    {
        [self soundPlay:SND_MOVE];
        
        [selectBtnArray addObject:btn];
        
        gNumber2 += numberArray[btn.tag];
        [self displayNumber2];
        if (gNumber2 > gNumber)
        {
            //오답
            [self unselectBtnAll];
            
            gNumber2 = 0;
            [self displayNumber2];
            [self panalty];
            
            gScore -= 10;
            if( gScore < 0)
                gScore = 0;
            
            [self displayMsg:@"-10" withX:btn.frame.origin.x andY:btn.frame.origin.y];
            [self displayScore];
            
            [self soundPlay:SND_MISS];
        }
        else if (gNumber2 == gNumber)
        {
            //정답
            
            for (int i=0; i<selectBtnArray.count; i++)
            {
                [self doCorrect:[selectBtnArray objectAtIndex:i]];
            }
            [self unselectBtnAll];
            
            if ( [self checkGameComplete] == YES )
            {
                [mTimer invalidate];
                mTimer = nil;
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Complete", @"")
                                                               message:[NSString stringWithFormat:NSLocalizedString(@"NextLevel", @""),gScore]
                                                              delegate:self 
                                                     cancelButtonTitle:nil 
                                                     otherButtonTitles:NSLocalizedString(@"OK", @""),nil];
                alert.tag = 0;
                [alert show];
                [alert release];
            }
            else
            {
                gNumber = [self getNumber];
                [self displayNumber];
            }

            gNumber2 = 0;
            [self displayNumber2];
            [self soundPlay:SND_GET_BONUS];
        }
        else
        {
            //nothing todo
        }
    }
    else
    {
        [self soundPlay:SND_MOVE];
        
        [selectBtnArray removeObject:btn];
        
        gNumber2 -= numberArray[btn.tag];
        if(gNumber2 < 0)
            gNumber2 = 0;
        [self displayNumber2];
        
    }
}

- (void) makeBtnImage: (UIButton *)btn
{
    //btn 이미지 교체
    NSString * strNumber;
    int number;
    int orgx, orgy;
    int x,y;
    
    number = [self randomRange:levelStartIdx[gLevel] max:levelEndIdx[gLevel]];
    strNumber = [NSString stringWithFormat:@"%i",number];

    numberArray[btn.tag] = number;
    orgx = gBtnOrignX[btn.tag];
    orgy = gBtnOrignY[btn.tag];

    [btn setBackgroundColor:[UIColor blackColor]];
    btn.selected = NO;
    btn.titleLabel.font = [UIFont systemFontOfSize:30];
    [btn setTitle:strNumber forState:UIControlStateNormal];
    
    x = btn.frame.origin.x + BTN_SIZE_X/2;
    y = btn.frame.origin.y + BTN_SIZE_Y/2;
    btn.frame = CGRectMake(x , y, 1, 1);
    btn.alpha = 0;
    [UIView beginAnimations:@"frame" context:nil];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    btn.frame = CGRectMake(orgx, orgy, BTN_SIZE_X, BTN_SIZE_Y);
    btn.alpha = 1;
    [UIView commitAnimations];
    btn.enabled = YES;
}

- (void) panalty
{
    int empty_count = 0;
    if (gRemainButtons == 25 )
        return;
    //빈곳 위치 설정
    int empty_loc = [self randomRange:1 max:25-gRemainButtons];
    for ( int i=0; i<25; i++ )
    {
        if (numberArray[i] == EMPTY_BUTTON)
        {
            empty_count ++;
        }
        
        if (empty_count == empty_loc)
        {
            [self makeBtnImage:[btnArray objectAtIndex:i]];
            break;
        }
    }
    gRemainButtons ++;
}

- (void) hideBtn: (UIButton *)btn
{
    int orgx, orgy;
    int x,y;
    
    numberArray[btn.tag] = EMPTY_BUTTON;
    
    //에니메이션
    orgx = btn.frame.origin.x;
    orgy = btn.frame.origin.y;
    x = btn.frame.origin.x + BTN_SIZE_X/2;
    y = btn.frame.origin.y + BTN_SIZE_Y/2;
    
    btn.enabled = NO;
    [UIView beginAnimations:@"frame" context:nil];
    btn.frame = CGRectMake(x , y, 1, 1);
    btn.alpha = 0;
    
    [UIView setAnimationDuration:ANIMATION_DURATION];
    
    [UIView commitAnimations];
    
    btn.frame = CGRectMake(orgx, orgy, BTN_SIZE_X, BTN_SIZE_Y); 
}

- (void) unselectBtnAll
{
    //선택 해제.
    for (int i=0; i<selectBtnArray.count; i++)
    {
        UIButton * tmpBtn = [selectBtnArray objectAtIndex:i];
        
        tmpBtn.selected = NO;
        [tmpBtn setBackgroundColor:[UIColor blackColor]];
    }
    [selectBtnArray removeAllObjects];
    gNumber2 = 0;
    [self displayNumber2];
}

#pragma mark IBAction
- (IBAction)hintBtnClick:(id)sender {
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)
    if ( gHintCount == 0 )
        return;
    
    gHintCount --;    
    [self displayHint];
    
    [self unselectBtnAll];
    
    UIButton * btn;
    
    for (int i=0; i<gSelectNumberCount; i++)
    {
        btn = [btnArray objectAtIndex:gSelectNumbers[i]];
        CGAffineTransform leftWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-5.0));
        CGAffineTransform rightWobble = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(5.0));
        
        btn.transform = leftWobble;  // starting point
        
        [UIView beginAnimations:@"wobble" context:btn];
        [UIView setAnimationRepeatAutoreverses:YES]; // important
        [UIView setAnimationRepeatCount:10];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(wobbleEnded:finished:context:)];
        
        btn.transform = rightWobble; // end here & auto-reverse
        
        [UIView commitAnimations];
    }
}

- (void) wobbleEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
    if ([finished boolValue]) {
        UIView* item = (UIView *)context;
        item.transform = CGAffineTransformIdentity;
    }
}

//폭탄 버튼이 눌리면... 레이블에 나온 모든 깃발 제거.
- (IBAction)bombBtnClick:(id)sender 
{
    if (gBombCount == 0)
        return;
    
    [self soundPlay:SND_BOMB];
    
    gBombCount --;
    [self displayBomb];
    
    [self unselectBtnAll];
    
    UIButton * btn;
    
    for (int i=0; i<gSelectNumberCount; i++)
    {
        int addscore;
        NSString * str;
        btn = [btnArray objectAtIndex:gSelectNumbers[i]];
        gRemainButtons --;
        [self soundPlay:SND_MOVE];
        addscore = (gRemainButtons + gSecond/10) * 10 + 100;
        gScore += addscore;
        
        str = [NSString stringWithFormat:@"+%i",addscore];
        
        //item check
        [self checkItem:btn];
        
        //점수
        [self displayScore];
        
        //btn 사라짐
        [self hideBtn:btn];
        
        [self displayMsg:str withX:btn.frame.origin.x andY:btn.frame.origin.y];
        
        if ( [self checkGameComplete] == YES )
        {
            [mTimer invalidate];
            mTimer = nil;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Complete", @"")
                                                           message:[NSString stringWithFormat:NSLocalizedString(@"NextLevel", @""),gScore]
                                                          delegate:self 
                                                 cancelButtonTitle:nil 
                                                 otherButtonTitles:NSLocalizedString(@"OK", @""),nil];
            alert.tag = 0;
            [alert show];
            [alert release];
            break;
        }
    }

    gNumber = [self getNumber];
    [self displayNumber];
    
    gNumber2 = 0;
    [self displayNumber2];
}


- (IBAction)menuBtnClick:(id)sender
{
    [mTimer invalidate];
    mTimer =nil;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"GameTitle", @"")
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Resume", @"")
                                              destructiveButtonTitle:NSLocalizedString(@"NewGame", @"")
                                                   otherButtonTitles:NSLocalizedString(@"Leaderboard", @""), nil];
    actionSheet.tag = 0;
    [actionSheet showInView:[self view]];
    [actionSheet release];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 0 && actionSheet.tag == 0 ) //New game
    {   
        gHintCount = 3;
        gBombCount = 3;
        gScore = 0;
        gLevel = 0;
        gSecond = 180;
        [self newGame];
        [self startTimer];
    }
    
    else if ( buttonIndex == 1 && actionSheet.tag == 0  ) //leaderboard view
    {
        [self showLeaderboard];
    }
    else
    {
        [self startTimer];
    }
}


#pragma mark - Timer
- (void) startTimer
{
    if(mTimer == nil)
    {
        mTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    }
    else
    {
        [mTimer invalidate];
        mTimer = nil;
        
        mTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    }
}

- (void) handleTimer:(NSTimer*)timer
{
    gSecond --;
    
    [self displaySecond];
    if( gSecond == 0)
    {
        //gameover
        [self displayGameOver];
    }
}

#pragma mark - Display (label , allert)

- (void) displayNumber
{
    NSString * strNumber;
    strNumber = [NSString stringWithFormat:@"%i",gNumber];
    [mlblNumber setText:strNumber]; 
}

- (void) displayNumber2
{
    NSString * strNumber;
    strNumber = [NSString stringWithFormat:@"%i",gNumber2];
    [mlblNumber2 setText:strNumber];
}

- (void) displayScore
{
    NSString * str;
    str = [NSString stringWithFormat:@"%i",gScore];
    [mlblScore setText:str];
}

- (void) displayLevel
{
    NSString * str;
    str = [NSString stringWithFormat:@"%i",gLevel + 1];
    [mlblLevel setText:str];
}

- (void) displayHint
{
    NSString * str;
    str = [NSString stringWithFormat:@"x%i",gHintCount];
    [mlblHint setText:str];
}

- (void) displayBomb
{
    NSString * str;
    str = [NSString stringWithFormat:@"x%i",gBombCount];
    [mlblBomb setText:str];   
}

- (void) displaySecond
{
    int min;
    int sec;
    min = gSecond / 60;
    sec = gSecond % 60;
    NSString * str = [NSString stringWithFormat:@"%02i:%02i", min,sec];
    [mlblTime setText:str];
    
    if(gSecond < 60)
    {
        [mlblTime setTextColor:[UIColor redColor]];
    }
    else
    {
        [mlblTime setTextColor:[UIColor whiteColor]];
    }
}

- (void) displayMsg:(NSString *)msg withX:(int)x andY:(int)y;
{
    //    if(!mOptDisplayEffect)
    //        return;
    
    [self.view bringSubviewToFront:mlblMsg];
    mlblMsg.frame = CGRectMake(x, y+20, 100, 20);
    mlblMsg.alpha = 1;
    mlblMsg.font = [UIFont fontWithName:@"Helvetica" size:22];
    
    mlblMsg.text = msg;
    
    [UIView beginAnimations:@"frame" context:nil];
    [UIView setAnimationDuration:ANIMATION_DURATION];
    mlblMsg.frame = CGRectMake(x, y-40, 100, 20);
    mlblMsg.alpha = 0;
    
    [UIView commitAnimations];
}
- (void) displayGameOver
{
#ifdef FREE_APP      
    [SPGameKitUtil sendScoreToGameCenter:gScore andId:@"addition_f"];
#else
    [SPGameKitUtil sendScoreToGameCenter:gScore andId:@"addition"];    
#endif
    
    [mTimer invalidate];
    mTimer =nil;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Game Over", @"")
                                                   message:[NSString stringWithFormat:NSLocalizedString(@"Your score", @""),gScore]
                                                  delegate:self 
                                         cancelButtonTitle:nil 
                                         otherButtonTitles:NSLocalizedString(@"Retry", @""), NSLocalizedString(@"Leaderboard", @""),nil];
    alert.tag= 1;
    [alert show];
    [alert release];    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //    //구매 사이트 연결 
    //    if ( buttonIndex == 1 && alertView.tag == 1)
    //    {
    //        NSURL * url = [[NSURL alloc]initWithString:NSLocalizedString(@"URL", @"")]; 
    //        [[UIApplication sharedApplication] openURL:url];
    //        [url release];
    //    }
    if ( buttonIndex == 0 && alertView.tag == 0 ) // next game
    {
        //alert의 결과로...... 하자
        gSecond += 60;
        gLevel += 1;
        
        if(gLevel == 10 ) //최대...
            gLevel = 9;
        
        [self newGame];
        [self startTimer];
    }
    
    if ( buttonIndex == 0 && alertView.tag == 1 ) //retry new game
    {   
        
        gBombCount = 3;
        gHintCount = 3;
        gScore = 0;
        gLevel = 0;
        gSecond = 180;
        [self newGame];
        [self startTimer];
    }
    
    if ( buttonIndex == 1 && alertView.tag == 1 ) //leaderboard view
    {
        [self showLeaderboard];
        
        gBombCount = 3;
        gHintCount = 3;
        gScore = 0;
        gLevel = 0;
        gSecond = 180;
        [self newGame];  
    }
}

#pragma mark - Calculate
- (int) randomRange:(int)minvalue max:(int)maxvalue
{
    return (rand() % (maxvalue - minvalue +1) + minvalue);
}

- (BOOL) checkGameComplete
{
    BOOL res = YES;
    
    if ( gRemainButtons == 0)
        res = YES;
    else
        res = NO;
    
    return res;
}

/*
 문제를 만든다. 
 1. 랜덤 개수 1~4
 2. 랜덤 개수 만큼 (랜덤 0 ~ 24)
 3. 이 인덱스의 수들을 합산 하여 리턴 
 
 */
- (int) getNumber
{
    int count;
    int idx;
    int res = 0;
    int tmpNumber[25]={0,};
    gSelectNumberCount = 0;
    
    count = [self randomRange:1 max:4];
    
    if (gRemainButtons < count)
    {
        count = gRemainButtons;
    }
    
    idx = 0;
    for (int i=0; i<25; i++)
    {
        if(numberArray[i] != EMPTY_BUTTON )
        {
            tmpNumber[idx] = numberArray[i];
            idx++;
        }
    }
        
    while (count != 0 )
    {
        idx = [self randomRange:0 max:gRemainButtons -1];
        if(tmpNumber[idx] != 0)
        {
            res += tmpNumber[idx];
            
            //선택번호 리스트 저장 (힌트 , 폭탄에서 사용)
            for (int i=0; i<25; i++)
            {
                if (tmpNumber[idx] == numberArray[i])
                {
                    gSelectNumbers[gSelectNumberCount] = i;
                    break;
                }
            }
            gSelectNumberCount ++;
            
            tmpNumber[idx] = 0;
            count --;
        }
    }
    return res; 
}

//정답 처리
- (void) doCorrect:(UIButton *)btn
{
    int addscore;
    NSString * str;
    
    gRemainButtons --;
    
    addscore = (gRemainButtons + gSecond/10) * 10;
    gScore += addscore;
    
    str = [NSString stringWithFormat:@"+%i",addscore];
    
    [self displayMsg:str withX:btn.frame.origin.x andY:btn.frame.origin.y];
    
    //item check
    [self checkItem:btn];
    
    //점수
    [self displayScore];
    
    //btn 사라짐
    [self hideBtn:btn];
}

- (void) checkItem:(UIButton *)btn
{
    int x = btn.frame.origin.x;
    int y = btn.frame.origin.y;
    int idx = btn.tag;
    
    switch (itemArray[idx]) {
        case ITEM_SCORE:
            gScore += 100;
            [self displayMsg:@"+100" withX:x andY:y];
            [self displayScore];
            [self soundPlay:SND_GET_BONUS];
            break;
            
        case ITEM_HINT:
            gHintCount ++;
            [self displayMsg:@"+HINT1" withX:x andY:y];
            [self displayHint];
            [self soundPlay:SND_GET_BONUS];
            break;
            
        case ITEM_BOMB:
            gBombCount ++;
            [self displayMsg:@"+BOMB1" withX:x andY:y];
            [self displayBomb];
            [self soundPlay:SND_GET_BONUS];
            break;
            
        case ITEM_TIME:
            gSecond += 30;
            [self displayMsg:@"+30sec" withX:x andY:y];
            [self displaySecond];
            [self soundPlay:SND_GET_BONUS];
            break;            
            
        default:
            break;
    }
    
    itemArray[idx] = ITEM_NONE;
}

#pragma mark - Sound Componenet
-(void) initSound
{
    mMoveSound = [[SPSoundEffect alloc] initWithSoundNameSysSnd:@"move" ofType:@"wav"];
    mBombSound = [[SPSoundEffect alloc] initWithSoundNameSysSnd:@"bomb" ofType:@"wav"];
    mShakeSound = [[SPSoundEffect alloc] initWithSoundNameSysSnd:@"shake" ofType:@"wav"];
    mMissSound = [[SPSoundEffect alloc] initWithSoundNameSysSnd:@"miss" ofType:@"wav"];
    mBonusSound = [[SPSoundEffect alloc] initWithSoundNameSysSnd:@"bonus" ofType:@"wav"];
}

-(void) releaseSound
{
    [mMoveSound release];
    mMoveSound = nil;
    [mBombSound release];
    [mShakeSound release];
    [mMissSound release];
    mMissSound =nil;
    [mBonusSound release];
    mBonusSound =nil;
}

-(void) soundPlay:(game_sound_id_type)snd_id
{
    //    if(mOptSoundEffect)
    //    {
    switch (snd_id) {
        case SND_MOVE:
            [mMoveSound play];
            break;
            
        case SND_BOMB:
            [mBombSound play];
            break;
            
        case SND_SHAKE:
            [mShakeSound play];
            break;
            
        case SND_MISS:
            [mMissSound play];
            break;
            
        case SND_GET_BONUS:
            [mBonusSound play];
            break;            
            
        default:
            break;
    }
    //    }
}

#pragma mark - leaderboard
- (void) showLeaderboard {
    GKLeaderboardViewController *leaderboardController = [[[GKLeaderboardViewController alloc] init]autorelease];
    if (leaderboardController != nil) {
        // 레더보드 델리게이트는 나임
        leaderboardController.leaderboardDelegate = self;
        
        // 레더보드를 현재 뷰에 모달로 띄운다.
        [self presentModalViewController:leaderboardController animated: YES];
    }
}

// 레더보드 델리게이트를 구현한 부분. 닫힐때 호출된다.
- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [self dismissModalViewControllerAnimated:YES]; //점수판 모달뷰를 내림
    // 추가적으로 자신의 어플에 맞게 구현해야할것이 있으면 한다.
    //[self startTimer];
}


- (void) showArchboard {
    GKAchievementViewController *archiveController = [[[GKAchievementViewController alloc]init] autorelease];
    
    if (archiveController != nil) {
        
        archiveController.achievementDelegate = self;
        
        [self presentModalViewController:archiveController animated: YES];
    }
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController{
    [self dismissModalViewControllerAnimated:YES];
}


#ifdef FREE_APP
#pragma mark iAD Delegate
-(void) adBannerInit
{
    adBanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    [adBanner setRequiredContentSizeIdentifiers:
     [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, nil]];
    
    [adBanner setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
    [adBanner setFrame:CGRectMake(0, 480, 320, 50)];
    [adBanner setDelegate:self];
    [self.view addSubview:adBanner];
    [adBanner release];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_isBannerVisible)
    {
        [UIView beginAnimations:@"animateBannerAppear" context:nil];
        [adBanner setFrame:CGRectMake(0, 430, 320, 50)];
        [UIView commitAnimations];
        _isBannerVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (_isBannerVisible)
    {
        [UIView beginAnimations:@"animateBannerOff" context:nil];
        //[adBanner setFrame:CGRectMake(0, 480, 320, 50)];
        adBanner.frame = CGRectOffset(adBanner.frame, 0, -50);
        [UIView commitAnimations];
    }
}

#pragma mark - CaulyAD

- (void)AddCaulyAD {
    
    float yPos = (self.view.frame.size.height - 48);
    
    if( [CaulyViewController moveBannerAD:self caulyParentview:nil xPos:0 yPos:yPos] == FALSE ) {
        NSLog(@"requestBannerAD failed");
    }
}
#endif

@end
