//
//  SPSoundEffect.m
//  BabySlidePuzzle
//
//  Created by sparrow on 11. 7. 2..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SPSoundEffect.h"


@implementation SPSoundEffect


- (id)initWithSoundNameAudioPlay:(NSString *)fileName ofType:(NSString *)type
{
    self = [super init];
        
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundPath];
    
    mAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    
    
    [fileURL release];
    
    mSndType = AUDIOPLAYER;
    
    return self;
}


- (void) play
{
    if(mSndType == AUDIOPLAYER)
        [mAudioPlayer play];
    else
        AudioServicesPlaySystemSound(mSoundID);
}

- (void) setVolume:(float)volume
{
    if(mSndType == AUDIOPLAYER)
        [mAudioPlayer setVolume:volume];
}

-(id) initWithSoundNameSysSnd:(NSString *)fileName ofType:(NSString *)type
{

    self = [super init];
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:soundPath], &mSoundID);
    
    mSndType = SYSTEMSOUND;
    
    return self;
}


-(BOOL) checkMediaPlayerPlayer
{
    MPMusicPlaybackState playbackstate = [[MPMusicPlayerController iPodMusicPlayer] playbackState];
    if(playbackstate == MPMusicPlaybackStatePlaying)
        return YES;
    else
        return NO;
}

-(void) audioShare
{
    [[AVAudioSession sharedInstance ] setCategory: AVAudioSessionCategoryPlayback error: nil];
    UInt32 doSetProperty = 1;
    AudioSessionSetProperty ( kAudioSessionProperty_OverrideCategoryMixWithOthers,
                             sizeof (doSetProperty),
                             &doSetProperty );
    [[AVAudioSession sharedInstance] setActive: YES error: nil];

}

- (void) release
{
    if(mSndType == AUDIOPLAYER)
        [mAudioPlayer release];
    else
        AudioServicesDisposeSystemSoundID(mSoundID);
    
    [super release];
}



@end