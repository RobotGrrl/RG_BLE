//
//  BLEManager.m
//  RoboBrrd Interact
//
//  Created by Erin Kennedy on 13-01-30.
//  Copyright (c) 2013 Erin Kennedy. All rights reserved.
//

#import "BLEManager.h"
#import "BLEDefines.h"
#import "DefaultsKeys.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@implementation BLEManager

static BLEManager *singleton = nil;

@synthesize bleDelegate;
@synthesize allPeripherals, allDescs, connected, selectedShield;
@synthesize bleManager, peripheral, scanTimer, refreshTimer;


#pragma mark - Singleton Management
+ (BLEManager *)singleton {
    
    if (nil != singleton) {
        return singleton;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        singleton = [[BLEManager alloc] init];
    });
    
    return singleton;
}


#pragma mark - Start

// called from the mainvc to start up the ble
// inits some stuff and starts the scan & refresh timers
- (void) startBLE {
    
    // Prepare Bluetooth Low Energy Manager
    DDLogInfo(@"Firing up BLE Manager");
    
    selectedShield = [NSNumber numberWithInt:0]; // default to 'any'
    
    connected = NO;
    
    allPeripherals = [[NSMutableArray alloc] initWithCapacity:1];
    allDescs = [[NSMutableArray alloc] initWithCapacity:1];
    
    bleManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.peripheral = [[CBPeripheral alloc] init];
    
    [self isLECapableHardware];
    
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timedScan:) userInfo:nil repeats:NO];
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timedRefresh:) userInfo:nil repeats:YES];
    
}

// starts the scan that is done by the blemanager (CBCentralManager)
- (void) timedScan:(NSTimer *)aTimer {
    DDLogInfo(@"starting scan");

    [bleManager scanForPeripheralsWithServices:nil
                                       options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey] ];

}

// called every 1 second, this looks at all the periph descs for the last advert
// if the last advert is > 15s (or whatever), then it deletes that periph
- (void) timedRefresh:(NSTimer *)aTimer {
    
    int i = 0;
    for(NSDictionary *dict in allDescs) {
     
        NSDate *advert = [dict objectForKey:@"LastAdvert"];
        
        NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *components = [calendar components:kCFCalendarUnitMinute|kCFCalendarUnitSecond
                                                   fromDate:advert
                                                     toDate:[NSDate date]
                                                    options:0];
        
        int s = components.second;
        
        if(s > 15) { // delete them after slightly longer than in the chooservc
            [allDescs removeObjectAtIndex:i];
            [allPeripherals removeObjectAtIndex:i];
        }
        
        i++;
    }
    
}

// this is mainly for blechooservc, where pressing a row will call this method
// gets the peripheral, and sets the blemanager to retrieve it
- (void) connectToPeripheral:(int)p {
    
    if(!connected) {
        CBPeripheral *peri = [allPeripherals objectAtIndex:p];
        if(peri == nil) return; // yikes?
        self.peripheral = peri;
        [bleManager retrievePeripherals:[NSArray arrayWithObject:self.peripheral]];
    }
    
}


#pragma mark - Stop

// this is always important with ble- sometimes if you don't disconnect properly, it
// can cause weird problems. also tell blemanager to stop scanning
- (void) disconnect {
    if(self.peripheral.isConnected) [bleManager cancelPeripheralConnection:self.peripheral];
    //[scanTimer invalidate];
    //scanTimer = nil;
    //[refreshTimer invalidate];
    //refreshTimer = nil;
    [bleManager stopScan];
}

// stopping the refresh timer
- (void) stopRefresh {
    [refreshTimer invalidate];
    refreshTimer = nil;
}


#pragma mark - Sending

// let's finally send some data! woo! we will create a byte array of 20 bytes to send out
// next is to choose which service & characteristic to used based off the different
// arduino shields / ble breakout boards we have added in
// finally, send the data!
// if 'any' (type of connection) is chosen, then we will "blast" every service & characteristic
// with the send data.
- (void) sendData:(NSString *)s {
    
    if(!connected) return;
    
    NSData *sendData;

    NSArray *bytesSeppArray = [s componentsSeparatedByString:@","];
    int numBytes = 0;
    unsigned char bytes[20];
    
    for(int i=0; i<[bytesSeppArray count]; i++) {
        NSString *parsed = [bytesSeppArray objectAtIndex:i];
        
        if([parsed length] > 1) {
            for(int j=0; j<[parsed length]; j++) {
                bytes[numBytes] = (unsigned char)[parsed characterAtIndex:j];
                numBytes++;
            }
        } else {        
            bytes[numBytes] = (unsigned char)[parsed characterAtIndex:0];
            numBytes++;
        }
        
    }
    
    sendData = [[NSData alloc] initWithBytes:bytes length:numBytes];
    
    
    CBUUID *uuidService;
    CBUUID *uuidChar;
    
    int ss = [selectedShield intValue];
    
    switch (ss) {
        case 0: {
            // any
            uuidService = [CBUUID UUIDWithString:roboBrrdServiceUUID];
            uuidChar = [CBUUID UUIDWithString:roboBrrdCharacteristicTXUUID];
        }
            break;
        case 1: {
            // kst
            uuidService = [CBUUID UUIDWithString:kstServiceUUID];
            uuidChar = [CBUUID UUIDWithString:kstCharacteristicTXUUID];
        }
            break;
        case 2: {
            // dr kroll
            uuidService = [CBUUID UUIDWithString:drkrollServiceUUID];
            uuidChar = [CBUUID UUIDWithString:drkrollCharacteristicTXUUID];
        }
            break;
        case 3: {
            // redbear
            uuidService = [CBUUID UUIDWithString:redbearServiceUUID];
            uuidChar = [CBUUID UUIDWithString:redbearCharacteristicTXUUID];
        }
            break;
        default:
            break;
    }
    
    
    for(CBService *aService in self.peripheral.services) {
        if([aService.UUID isEqual:uuidService] || ss == 0) {
            for(CBCharacteristic *aCharacteristic in aService.characteristics) {
                if([aCharacteristic.UUID isEqual:uuidChar] || ss == 0) {
                    [self.peripheral writeValue:sendData forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse];
                }
            }
        }
    }
    
}


#pragma mark - CBPeripheralDelegate Methods

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in aPeripheral.services) {
        DDLogInfo(@"Service Discovered: %@", aService);
        [aPeripheral discoverCharacteristics:nil forService:aService];
    }
}

- (void)peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    for (CBCharacteristic *aChar in service.characteristics) {
        DDLogInfo(@"Characteristic Discovered: %@", aChar);
        [aPeripheral readValueForCharacteristic:aChar];
        [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
    }
    
}

// here is where we receive incomming data
// create a quick dictionary with the data, and fire the delegate
- (void)peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    NSString *someString = [[NSString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
    DDLogInfo(@"Incoming byte data: %@", someString);
    DDLogInfo(@"data: %@", (characteristic.value));
    
    [aPeripheral readRSSI];
    
    NSString *theAttributeNumber = @"Robobrrd Data Characteristic";
    NSNumber *aRSSI = [aPeripheral RSSI];
    NSDate *aTimestamp = [NSDate new];
    NSString *aDescription = @"RoboBrrd Speaks!";
    
    
    if( [characteristic.value length] > 0) {
        NSDictionary *newCharacteristic = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:characteristic, theAttributeNumber, aRSSI, characteristic.value, aTimestamp, aDescription, nil]
                                                                        forKeys:[NSArray arrayWithObjects:@"characteristic", @"attributeNumber", @"RSSI", @"data", @"timestamp", @"description", nil]];
        
        // Fire the delegate!  Raise Shields!
        [bleDelegate incomingData:newCharacteristic];
    }
    
    
    if([selectedShield intValue] == 3) { // redbear shield is weird
        
        CBUUID *uuidService = [CBUUID UUIDWithString:redbearServiceUUID];
        CBUUID *uuidChar = [CBUUID UUIDWithString:redbearResetRXUUID];
        unsigned char bytes[] = {0x01};
        NSData *d = [[NSData alloc] initWithBytes:bytes length:1];
        
        for(CBService *aService in self.peripheral.services) {
            if([aService.UUID isEqual:uuidService]) {
                for(CBCharacteristic *aCharacteristic in aService.characteristics) {
                    if([aCharacteristic.UUID isEqual:uuidChar]) {
                        [self.peripheral writeValue:d forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse];
                    }
                }
            }
        }
        
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    DDLogVerbose(@"wrote");
    //NSLog(@"Successfully wrote to %@ (characteristic) of %@ (service) with %@ (error).", characteristic.UUID, characteristic.service.UUID, error);
}


#pragma mark - CBCentralDelegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self isLECapableHardware];
}

// this is where new advertisements are caught
// create a dictionary with the description of the advert (if we haven't seen the periph already)
// if we have seen the periph, update the desc dict with the latest advert date and rssi
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if(![allPeripherals containsObject:aPeripheral]) {
        DDLogVerbose(@"Advert: %@ (%d dBm)", advertisementData, [RSSI intValue]);
        [allPeripherals addObject:aPeripheral];
        
        NSMutableArray *objs = [[NSMutableArray alloc] initWithCapacity:4];
        [objs addObject:aPeripheral];
        [objs addObject:[aPeripheral name]];
        [objs addObject:RSSI];
        [objs addObject:[NSDate date]];
        
        NSDictionary *about = [NSDictionary dictionaryWithObjects:objs forKeys:[NSArray arrayWithObjects:@"Peripheral", @"Name", @"RSSI", @"LastAdvert", nil]];
        [allDescs addObject:about];
        
        [objs release];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewPeripheral" object:nil];
        
    } else {
        printf("a");
        
        int i = 0;
        for(CBPeripheral *le in allPeripherals) {
            if(aPeripheral == le) break;
            i++;
        }
        
        NSMutableDictionary *dict = [[allDescs objectAtIndex:i] mutableCopy];
        [dict setObject:[NSDate date] forKey:@"LastAdvert"];
        [dict setObject:RSSI forKey:@"RSSI"];
        
        [allDescs replaceObjectAtIndex:i withObject:dict];
        
    }
    
}

// here is where we connect to the peripheral
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    DDLogVerbose(@"retrieved peripherals");
    
    // If you're not connected to this retrieved peripheral, do it.
    if(!self.peripheral.isConnected) {
        DDLogInfo(@"going to connect!");
        [bleManager connectPeripheral:self.peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
    
}

// yay! here is where we connected to the periph
// update some stuff & stop the refresh timer (we don't need it now)
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral {
    DDLogInfo(@"connected to peripheral");
    
    connected = YES;
    self.peripheral = aPeripheral;
    
    [self.peripheral setDelegate:self];
    [self.peripheral discoverServices:nil];
    [bleDelegate nowConnected];
    
    [self stopRefresh];
    
}

// boohoo, here's where the periph is disconnected
// make sure to delete the desc and periph object
// also restart the scan & refresh timers
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error {
    DDLogInfo(@"disconnected peripherals with error: %@", [error localizedDescription]);
    
    connected = NO;
    
    int i = 0;
    for(CBPeripheral *periph in allPeripherals) {
        
        if(periph == aPeripheral) {
            [allDescs removeObjectAtIndex:i];
            [allPeripherals removeObjectAtIndex:i];
        }
        
        i++;
    }
    
    if(self.peripheral == aPeripheral) {
        self.peripheral = nil;
        [bleDelegate nowDisconnected];
        scanTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timedScan:) userInfo:nil repeats:NO];
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timedRefresh:) userInfo:nil repeats:YES];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error {
    DDLogInfo(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
}


#pragma mark - A Propos MainViewController

- (NSString *) periphUUID {
    // TODO: not sure if this works
    CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, [peripheral UUID]);
    
    //NSString *s = (__bridge NSString*)uuidStr;
    NSString *s = (NSString *)uuidStr;
    
    return s;
}

- (NSString *) periphName {
    return [peripheral name];
}

- (void) connectToDefault {
    // ok, let's try this
    
    if(connected) return; // already connected don't do anything
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *givenUUID = [userDefaults objectForKey:defaultDeviceUUIDKey];
    NSString *givenName = [userDefaults objectForKey:defaultDeviceNameKey];
    //CBUUID *zeeUUID = [CBUUID UUIDWithString:givenUUID];
    CFUUIDRef zeeUUID = CFUUIDCreateFromString(kCFAllocatorDefault, (CFStringRef)givenUUID);
    
    int i = 0;
    for(CBPeripheral *periph in allPeripherals) {
        
        if(periph.UUID == zeeUUID) {
            DDLogVerbose(@"same UUID");
            if([periph.name isEqualToString:givenName]) {
                DDLogInfo(@"same name - let's try to connect");
                self.peripheral = periph;
                [bleManager retrievePeripherals:[NSArray arrayWithObject:self.peripheral]];
            }
        }
        
        i++;
    }
    
}


#pragma mark - Helpers

- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([bleManager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            DDLogInfo(@"Central is powered; ready to roll.");
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    return FALSE;
}

- (int)convertHexStringToIntegerValue:(NSString *)string {
	NSScanner *scanner = [[NSScanner alloc] initWithString:string];
	unsigned int retval;
	if (![scanner scanHexInt:&retval]) {
        return 0;
	}
	return retval;
}

@end
