//
//  SPGameKitUtil.h
//  sparrow sudoku free
//
//  Created by JUN HO CHOI on 11. 9. 9..
//  Copyright 2011년 SPARROW APPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface SPGameKitUtil : NSObject{
    
}

/////////////////Geunwon,Mo : GameCenter 추가 start /////////////
+ (BOOL) isGameCenterAvailable ; //게임센터가 사용가능하지 알아보는 메소드
+ (void) connectGameCenter; //게임센터에 접속하는 메소드
//+(void) sendScoreToGameCenter:(int)_score; //게임센터서버에 점수 보내는 메소드
+(void) sendScoreToGameCenter:(int)_score andId:(NSString *)str_id;
+ (void) sendAchievementWithIdentifier: (NSString*) identifier percentComplete: (float) percent;//게임센터서버에 목표달성 보내는 메소드
+ (void) resetAchievements; //테스트용으로 목표달성도를 리셋하는 메소드
/////////////////Geunwon,Mo : GameCenter 추가 end   /////////////

@end
