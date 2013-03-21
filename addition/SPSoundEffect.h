//
//  SPSoundEffect.h
//  BabySlidePuzzle
//
//  Created by sparrow on 11. 7. 2..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>


typedef enum {
    AUDIOPLAYER =0,
    SYSTEMSOUND,
} soundType;

@interface SPSoundEffect : NSObject {
    AVAudioPlayer * mAudioPlayer;
    SystemSoundID mSoundID;
    
    soundType mSndType;
}

-(id) initWithSoundNameAudioPlay:(NSString *)fileName ofType:(NSString *)type;
-(id) initWithSoundNameSysSnd:(NSString *)fileName ofType:(NSString *)type;

-(void) play;
-(void) setVolume:(float)volume;

-(BOOL) checkMediaPlayerPlayer;
-(void) audioShare;


-(void) release;

@end
