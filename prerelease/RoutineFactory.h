//
//  RoutineFactory.h
//  BloopBloop
//
//  Created by Erin Kennedy on 13-06-11.
//  Copyright (c) 2013 Erin Kennedy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BLEManager.h"

#define kLeftArm @"left_arm"
#define kRightArm @"right_arm"
#define kHead @"head"
#define kEyes @"eyes"


#define uLeftArm @"L"
#define uRightArm @"R"
#define uHead @"H"
#define uEyes @"E"


#define aWave @"wave"
#define aShake @"shake"
#define aWiggle @"wiggle"

#define leftArmUp 160
#define leftArmMiddle 90
#define leftArmDown 0

#define rightArmUp 160
#define rightArmMiddle 90
#define rightArmDown 0

#define headLeft 60
#define headMiddle 90
#define headRight 120

#define kLedColour @"led_colour"



@interface RoutineFactory : NSObject {

    NSMutableArray *routine;
    NSMutableDictionary *routineInfo;
    BOOL playingRoutine;
    int currentFrame;
    NSTimer *playTimer;
    
    NSTimer *readWatchdog;
    
    int readFrame;
    
}

@property (nonatomic, retain) NSMutableArray *routine;
@property (nonatomic, retain) NSMutableDictionary *routineInfo;
@property (nonatomic, retain) NSTimer *playTimer;
@property (nonatomic, retain) NSTimer *readWatchdog;

- (void) receiveNotification:(NSNotification *) notification;
- (void) playRoutine:(NSTimer *)aTimer;
- (void) stopPlayTimer;
- (NSString *) formulateCmd:(NSNumber *)type userInfo:(NSDictionary *)userInfo;
- (void) schedulePlay:(NSNumber *)interval;
- (void) startRoutine:(NSDictionary *)userInfo;

@end
