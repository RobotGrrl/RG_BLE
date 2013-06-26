//
//  BLEManager.h
//  RoboBrrd Interact
//
//  Created by Erin Kennedy on 13-01-30.
//  Copyright (c) 2013 Erin Kennedy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "DDLog.h"

@protocol BLEManagerDelegate <NSObject>
-(void) incomingData:(NSDictionary *)dataDictionary;
-(void) nowDisconnected;
-(void) nowConnected;
@end

@interface BLEManager : NSObject <CBPeripheralDelegate, CBCentralManagerDelegate> {
    
    id <BLEManagerDelegate> bleDelegate;
    
    NSMutableArray *allPeripherals;
    NSMutableArray *allDescs;
    BOOL connected;
    NSNumber *selectedShield;
    
@private
    CBCentralManager *bleManager;
    CBPeripheral *peripheral;
    NSTimer *scanTimer;
    NSTimer *refreshTimer;
    
}

+(id)singleton;

@property (nonatomic, strong) id <BLEManagerDelegate> bleDelegate;
@property (nonatomic, retain) NSMutableArray *allPeripherals;
@property (nonatomic, retain) NSMutableArray *allDescs;

@property (nonatomic, retain) CBCentralManager *bleManager;
@property (nonatomic, retain) CBPeripheral *peripheral;
@property (nonatomic, retain) NSTimer *scanTimer;
@property (nonatomic, retain) NSTimer *refreshTimer;

@property (assign) BOOL connected;

@property (nonatomic, retain) NSNumber *selectedShield;

- (void) startBLE;
- (void) timedScan:(NSTimer *)aTimer;
- (void) timedRefresh:(NSTimer *)aTimer;
- (void) connectToPeripheral:(int)p;

- (void) disconnect;
- (void) stopRefresh;

- (void) sendData:(NSString *)s;

- (NSString *) periphUUID;
- (NSString *) periphName;
- (void) connectToDefault;

- (int) convertHexStringToIntegerValue:(NSString *)string;

@end
