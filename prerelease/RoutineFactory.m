//
//  RoutineFactory.m
//  BloopBloop
//
//  Created by Erin Kennedy on 13-06-11.
//  Copyright (c) 2013 Erin Kennedy. All rights reserved.
//

#import "RoutineFactory.h"

@implementation RoutineFactory

@synthesize routine, routineInfo, playTimer, readWatchdog;

- (id)init {
    self = [super init];
    if (self) {
        // Initialize self.
        
        routine = [[NSMutableArray alloc] initWithCapacity:5];
        routineInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveNotification:)
                                                     name:@"ResponseRX"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveNotification:)
                                                     name:@"Disconnected"
                                                   object:nil];
        
        
    }
    return self;
}


- (void) startRoutine:(NSDictionary *)userInfo {
    
    [routine removeAllObjects];
    
    NSString *key = [userInfo objectForKey:@"key"];
    NSNumber *repeat = [userInfo objectForKey:@"repeat"];
    
    [routineInfo setObject:repeat forKey:@"repeat"];
    [routineInfo setObject:[NSNumber numberWithBool:NO] forKey:@"done"];
    
    if([key isEqualToString:kLeftArm]) {
        
        NSString *action = [userInfo objectForKey:@"action"];
        
        if([action isEqualToString:aWave]) {
        
            NSMutableDictionary *cmdDict = [[NSMutableDictionary alloc] initWithCapacity:3];
            NSMutableDictionary *frameInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
            [cmdDict setObject:key forKey:@"key"];
            [cmdDict setObject:@"x" forKey:@"readexe"];
            int counter = 0;
            NSNumber *cmdType = [NSNumber numberWithInt:1];
            
            
            [cmdDict setObject:[NSNumber numberWithInt:leftArmUp] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:500] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:leftArmUp-20] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:leftArmUp] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:leftArmDown] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:500] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            
            NSLog(@"%@", [routine objectAtIndex:0]);
            
            playingRoutine = YES;
            currentFrame = 0;
            readFrame = 0;
            [self schedulePlay:[[routine objectAtIndex:currentFrame] objectForKey:@"delay"]];
            
        } else if([action isEqualToString:aWiggle]) {
            
            NSMutableDictionary *cmdDict = [[NSMutableDictionary alloc] initWithCapacity:3];
            NSMutableDictionary *frameInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
            [cmdDict setObject:key forKey:@"key"];
            [cmdDict setObject:@"x" forKey:@"readexe"];
            int counter = 0;
            NSNumber *cmdType = [NSNumber numberWithInt:1];
            
            
            [cmdDict setObject:[NSNumber numberWithInt:leftArmMiddle] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:250] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:leftArmMiddle-20] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:leftArmMiddle+20] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:leftArmMiddle-20] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:leftArmDown] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:250] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            
            NSLog(@"%@", [routine objectAtIndex:0]);
            
            playingRoutine = YES;
            currentFrame = 0;
            readFrame = 0;
            [self schedulePlay:[[routine objectAtIndex:currentFrame] objectForKey:@"delay"]];
            
        }
        
        
    } else if([key isEqualToString:kRightArm]) {
        
        NSString *action = [userInfo objectForKey:@"action"];
        
        if([action isEqualToString:aWave]) {
            
            NSMutableDictionary *cmdDict = [[NSMutableDictionary alloc] initWithCapacity:3];
            NSMutableDictionary *frameInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
            [cmdDict setObject:key forKey:@"key"];
            [cmdDict setObject:@"x" forKey:@"readexe"];
            int counter = 0;
            NSNumber *cmdType = [NSNumber numberWithInt:1];
            
            
            [cmdDict setObject:[NSNumber numberWithInt:rightArmUp] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:500] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:rightArmUp-20] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:rightArmUp] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:rightArmDown] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:500] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            
            NSLog(@"%@", [routine objectAtIndex:0]);
            
            playingRoutine = YES;
            currentFrame = 0;
            readFrame = 0;
            [self schedulePlay:[[routine objectAtIndex:currentFrame] objectForKey:@"delay"]];
            
        }  else if([action isEqualToString:aWiggle]) {
            
            NSMutableDictionary *cmdDict = [[NSMutableDictionary alloc] initWithCapacity:3];
            NSMutableDictionary *frameInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
            [cmdDict setObject:key forKey:@"key"];
            [cmdDict setObject:@"x" forKey:@"readexe"];
            int counter = 0;
            NSNumber *cmdType = [NSNumber numberWithInt:1];
            
            
            [cmdDict setObject:[NSNumber numberWithInt:rightArmMiddle] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:250] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:rightArmMiddle-20] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:rightArmMiddle+20] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:rightArmMiddle-20] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:rightArmDown] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:250] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            
            NSLog(@"%@", [routine objectAtIndex:0]);
            
            playingRoutine = YES;
            currentFrame = 0;
            readFrame = 0;
            [self schedulePlay:[[routine objectAtIndex:currentFrame] objectForKey:@"delay"]];
            
        }
        
    } else if([key isEqualToString:kHead]) {
        
        NSString *action = [userInfo objectForKey:@"action"];
        
        if([action isEqualToString:aShake]) {
            
            NSMutableDictionary *cmdDict = [[NSMutableDictionary alloc] initWithCapacity:3];
            NSMutableDictionary *frameInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
            [cmdDict setObject:key forKey:@"key"];
            [cmdDict setObject:@"x" forKey:@"readexe"];
            int counter = 0;
            NSNumber *cmdType = [NSNumber numberWithInt:1];
            
            
            [cmdDict setObject:[NSNumber numberWithInt:headLeft] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:250] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:headRight] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:400] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:headLeft] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:400] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:headMiddle] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:250] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            
            NSLog(@"%@", [routine objectAtIndex:0]);
            
            playingRoutine = YES;
            currentFrame = 0;
            readFrame = 0;
            [self schedulePlay:[[routine objectAtIndex:currentFrame] objectForKey:@"delay"]];
            
        }  else if([action isEqualToString:aWiggle]) {
            
            NSMutableDictionary *cmdDict = [[NSMutableDictionary alloc] initWithCapacity:3];
            NSMutableDictionary *frameInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
            [cmdDict setObject:key forKey:@"key"];
            [cmdDict setObject:@"x" forKey:@"readexe"];
            int counter = 0;
            NSNumber *cmdType = [NSNumber numberWithInt:1];
            
            
            [cmdDict setObject:[NSNumber numberWithInt:headMiddle] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:250] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:headMiddle-20] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:headMiddle+20] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:headMiddle-20] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:100] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            [cmdDict setObject:[NSNumber numberWithInt:headMiddle] forKey:@"val"];
            [cmdDict setObject:[NSNumber numberWithInt:counter] forKey:@"index"];
            [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
            [frameInfo setObject:[NSNumber numberWithInt:250] forKey:@"delay"];
            [routine addObject:[frameInfo copy]];
            counter++;
            
            
            NSLog(@"%@", [routine objectAtIndex:0]);
            
            playingRoutine = YES;
            currentFrame = 0;
            readFrame = 0;
            [self schedulePlay:[[routine objectAtIndex:currentFrame] objectForKey:@"delay"]];
            
        }
        
    } else if([key isEqualToString:kEyes]) {
        
        NSArray *dataum = [userInfo objectForKey:@"data"];
        
        NSMutableDictionary *cmdDict = [[NSMutableDictionary alloc] initWithCapacity:3];
        NSMutableDictionary *frameInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
        [cmdDict setObject:key forKey:@"key"];
        int counter = 0;
        NSNumber *cmdType = [NSNumber numberWithInt:2];
        
        [cmdDict setObject:@"R" forKey:kLedColour];
        [cmdDict setObject:[dataum objectAtIndex:0] forKey:@"val"];
        [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
        [frameInfo setObject:[NSNumber numberWithInt:50] forKey:@"delay"];
        [routine addObject:[frameInfo copy]];
        counter++;
        
        [cmdDict setObject:@"G" forKey:kLedColour];
        [cmdDict setObject:[dataum objectAtIndex:1] forKey:@"val"];
        [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
        [frameInfo setObject:[NSNumber numberWithInt:50] forKey:@"delay"];
        [routine addObject:[frameInfo copy]];
        counter++;
        
        [cmdDict setObject:@"B" forKey:kLedColour];
        [cmdDict setObject:[dataum objectAtIndex:2] forKey:@"val"];
        [frameInfo setObject:[self formulateCmd:cmdType userInfo:cmdDict] forKey:@"command"];
        [frameInfo setObject:[NSNumber numberWithInt:50] forKey:@"delay"];
        [routine addObject:[frameInfo copy]];
        counter++;
        
        NSLog(@"%@", [routine objectAtIndex:0]);
        
        playingRoutine = YES;
        currentFrame = 0;
        readFrame = 0;
        [self schedulePlay:[[routine objectAtIndex:currentFrame] objectForKey:@"delay"]];
        
    }
    
    
}


- (void) schedulePlay:(NSNumber *)interval {
    
    float zeeInterval = ([interval floatValue]/1000);
    
    NSLog(@"schedule play: %f", zeeInterval);
    
    NSDate *d = [NSDate dateWithTimeIntervalSinceNow:zeeInterval];
    playTimer = [[NSTimer alloc] initWithFireDate:d interval:1.0 target:self selector:@selector(playRoutine:) userInfo:nil repeats:NO];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:playTimer forMode:NSDefaultRunLoopMode];
    
}

- (void) stopPlayTimer {
    if(playTimer != nil) {
        [playTimer invalidate];
        playTimer = nil;
    }
}

- (void) playRoutine:(NSTimer *)aTimer {

    NSLog(@"play routine");
    
    if(!playingRoutine) return;
    
    NSDictionary *frame = [routine objectAtIndex:currentFrame];
    NSString *command = [frame objectForKey:@"command"];
    
    NSLog(@"%d command: %@", currentFrame, command);
    
    [[BLEManager singleton] sendData:command];
    [self startReadWatchdog];
    
    currentFrame++;
    
    [self stopPlayTimer];
    
}

- (void) startReadWatchdog {
    
    NSNumber *delay = [[routine objectAtIndex:currentFrame] objectForKey:@"delay"];
    float zeeDelay = ([delay floatValue]/1000)+0.5;
    
    NSDate *d = [NSDate dateWithTimeIntervalSinceNow:zeeDelay];
    readWatchdog = [[NSTimer alloc] initWithFireDate:d interval:1.0 target:self selector:@selector(readerWatchdog:) userInfo:nil repeats:NO];
    
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:readWatchdog forMode:NSDefaultRunLoopMode];
    
}

- (void) readerWatchdog:(NSTimer *)aTimer {
    
    BOOL caught = NO;
    
    NSLog(@"current frame: %d , read frame: %d", currentFrame, readFrame);
    
    [self stopReadWatchdog];
    
    if(currentFrame-1 == readFrame) {
        caught = YES;
    }
    
    if(caught) {
        currentFrame = readFrame;
        NSLog(@"We have to send it again %d", currentFrame);
        [self schedulePlay:[NSNumber numberWithFloat:0.5]];
    }
    
    
    /*
    if(currentFrame-1 == readFrame) {
        caught = YES;
    }
    
    [self stopReadWatchdog];
    
    if(caught) {
        int gg = 0;
        if(readFrame == 0) {
            gg = 0;
        } else {
            gg = readFrame-1;
        }
        currentFrame = gg;
        NSLog(@"We have to send it again? %d", currentFrame);
        [self schedulePlay:[NSNumber numberWithInt:0]];
        currentFrame--; // TODO: tomorrow this is the place to figure it out
    } else {
        NSLog(@"Nothing different: read: %d current: %d", readFrame, currentFrame);
        
        if(currentFrame == ([routine count]-1)) {
            currentFrame = 0;
            readFrame = 0;
        }
     
    }
     */
    
}

- (void) stopReadWatchdog {
    if(readWatchdog != nil) {
        [readWatchdog invalidate];
        readWatchdog = nil;
    }
}




- (void) receiveNotification:(NSNotification *) notification {
    
    //if(!playingRoutine) return;
    
    if ([[notification name] isEqualToString:@"ResponseRX"]) {
        
        BOOL success = [[[notification userInfo] objectForKey:@"success"] boolValue];
        
        NSLog(@"WTF");
        
        if(success) {
            NSLog(@"yes1");
            
            [self stopReadWatchdog];
            
            if(readFrame == ([routine count])) {
                currentFrame = 0;
                readFrame = 0;
                playingRoutine = NO;
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"RoutineComplete"
                 object:self];
                
            } else {
                readFrame++;
                if([routine count] > 0) {
                    if(currentFrame < [routine count]) {
                        [self schedulePlay:[[routine objectAtIndex:currentFrame] objectForKey:@"delay"]];
                    } else {
                        // we are done?
                        currentFrame = 0;
                        readFrame = 0;
                        playingRoutine = NO;
                        
                        [[NSNotificationCenter defaultCenter]
                         postNotificationName:@"RoutineComplete"
                         object:self];
                        
                    }
                
                }
            }
            
        } else {
            NSLog(@"no1");
            [self stopReadWatchdog];
            
            /*
            NSString *response = [[notification userInfo] objectForKey:@"string"];
            
            char digit0 = [response characterAtIndex:1];
            char digit1 = [response characterAtIndex:0];
            
            int zeeLastIndex = 0;
            
            if(digit1 == '0') {
                zeeLastIndex = digit0-'0';
                //zeeLastIndex = digit0;
            } else {
                zeeLastIndex = digit0-'0';
                zeeLastIndex += ((digit1-'0')*10);
                //zeeLastIndex = digit0;
                //zeeLastIndex += ((digit1)*10);
            }
            
            NSLog(@"Zee last index: %d digits: %d %d", zeeLastIndex, digit1, digit0);
            
            if([routine count] > 0) {
                currentFrame = zeeLastIndex;
                [self schedulePlay:[NSNumber numberWithInt:0]];
            }
             */
            
            
            if([[[notification userInfo] objectForKey:@"string"] isEqualToString:@"99"]) {
                NSLog(@"ooh noo LEDs");
                [self schedulePlay:[NSNumber numberWithInt:0]];
                
                
            } else {
                
                
                // sometimes the index gets messed up too
                if([routine count] > 0) {
                    currentFrame = readFrame;
                    NSLog(@"let's try %d", currentFrame);
                    [self schedulePlay:[NSNumber numberWithInt:0]];
                }
                
                
            }
            
            
        }
    }
    
    if([[notification name] isEqualToString:@"Disconnected"]) {
        [self stopPlayTimer];
        [self stopReadWatchdog];
    }
    
    
    if ([[notification name] isEqualToString:@"ResponseTX"]) {
        
        
        
        
    }
    
    
}


- (NSString *) formulateCmd:(NSNumber *)type userInfo:(NSDictionary *)userInfo {
    
    NSString *command = @"";
    
    switch ([type intValue]) {
        case 0: {
            // ~ <key> , <action> , <index> , !
        
        }
            break;
        case 1: {
            // # <key> , <val> , <read/execute> , <index> , !
            
            NSString *givenKey = [userInfo objectForKey:@"key"];
            NSNumber *givenVal = [userInfo objectForKey:@"val"];
            NSNumber *givenIndex = [userInfo objectForKey:@"index"];
            NSString *readExe = [userInfo objectForKey:@"readexe"];
            
            NSString *key = @"";
            
            if([givenKey isEqualToString:kLeftArm]) {
                key = uLeftArm;
            } else if([givenKey isEqualToString:kRightArm]) {
                key = uRightArm;
            } else if([givenKey isEqualToString:kHead]) {
                key = uHead;
            }
            
            NSString *val = @"";
            
            if([givenVal intValue] < 10) {
                val = [NSString stringWithFormat:@"00%d", [givenVal intValue]];
            } else if([givenVal intValue] < 100) {
                val = [NSString stringWithFormat:@"0%d", [givenVal intValue]];
            } else {
                val = [NSString stringWithFormat:@"%d", [givenVal intValue]];
            }
            
            NSString *index = @"";
            
            if([givenIndex intValue] < 10) {
                index = [NSString stringWithFormat:@"0%d", [givenIndex intValue]];
            } else {
                index = [NSString stringWithFormat:@"%d", [givenIndex intValue]];
            }
            
            command = [NSString stringWithFormat:@"~%@,%@,%@,%@,!", key, val, readExe, index];
            
            }
            break;
            
        case 2: {
            
            // ^ <led key> , <led> , <val> , !
            
            NSString *givenKey = [userInfo objectForKey:@"key"];
            NSString *givenColour = [userInfo objectForKey:kLedColour];
            NSNumber *givenVal = [userInfo objectForKey:@"val"];
            
            NSString *key = @"";
            if([givenKey isEqualToString:kEyes]) {
                key = uEyes;
            }
            
            NSString *colour = givenColour;
            
            NSString *val = @"";
            if([givenVal intValue] < 10) {
                val = [NSString stringWithFormat:@"00%d", [givenVal intValue]];
            } else if([givenVal intValue] < 100) {
                val = [NSString stringWithFormat:@"0%d", [givenVal intValue]];
            } else {
                val = [NSString stringWithFormat:@"%d", [givenVal intValue]];
            }
            
            command = [NSString stringWithFormat:@"^%@,%@,%@,!", key, colour, val];
            
            
            }
            break;
            
        default:
            break;
    }
    
    return command;
    
}

@end
