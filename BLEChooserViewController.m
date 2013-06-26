//
//  BLEChooserViewController.m
//  RoboBrrd Interact
//
//  Created by Erin Kennedy on 13-01-29.
//  Copyright (c) 2013 Erin Kennedy. All rights reserved.
//

#import "BLEChooserViewController.h"
#import "BLEManager.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

@interface BLEChooserViewController ()

@end

@implementation BLEChooserViewController

@synthesize leTableView, activityInd, connectButton, disconnectButton, shieldSegment;
@synthesize allPeripherals, allDescs,refreshTimer, justTheDiscButton;

#pragma mark - View

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopRefresh];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    selectedCell = 99;
    connectButton.enabled = NO;
    [connectButton setAlpha:0.6];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newPeripheralNotification:)
                                                 name:@"NewPeripheral"
                                               object:nil];
    
    self.allPeripherals = [NSArray arrayWithArray:[[BLEManager singleton] allPeripherals]];
    self.allDescs = [NSArray arrayWithArray:[[BLEManager singleton] allDescs]];
    
    //refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timedRefresh:) userInfo:nil repeats:YES];
    [self startRefresh];
    
    
    // -- accessibility
    // (yes, the indexes are backwards)
    [[[shieldSegment subviews] objectAtIndex:3] setAccessibilityLabel:@"Any"];
    [[[shieldSegment subviews] objectAtIndex:3] setAccessibilityHint:@"Use to connect to any BLE module"];
    
    [[[shieldSegment subviews] objectAtIndex:2] setAccessibilityLabel:@"KST"];
    [[[shieldSegment subviews] objectAtIndex:2] setAccessibilityHint:@"Use to connect to BLE module from KST"];
    
    [[[shieldSegment subviews] objectAtIndex:1] setAccessibilityLabel:@"Dr. Kroll"];
    [[[shieldSegment subviews] objectAtIndex:1] setAccessibilityHint:@"Use to connect to Dr.Kroll BLE shield"];
    
    [[[shieldSegment subviews] objectAtIndex:0] setAccessibilityLabel:@"RedBear"];
    [[[shieldSegment subviews] objectAtIndex:0] setAccessibilityHint:@"Use to connect to RedBear BLE shield"];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    //if(selectedCell == 99) return; // ??
    
    self.justTheDiscButton = NO;
    
    if([[BLEManager singleton] connected]) {
        connectButton.enabled = NO;
        [connectButton setAlpha:0.6];
        disconnectButton.enabled = YES;
        [disconnectButton setAlpha:1.0];
        [activityInd startAnimating];
    } else {
        [activityInd stopAnimating];
        connectButton.enabled = YES;
        [connectButton setAlpha:1.0];
        disconnectButton.enabled = NO;
        [disconnectButton setAlpha:0.6];
        
        [self startRefresh];
        selectedCell = 99;
        [leTableView reloadData];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Timers

- (void) startRefresh {
    
    if(refreshTimer == nil) {
        NSDate *d = [NSDate dateWithTimeIntervalSinceNow:0.5];
        refreshTimer = [[NSTimer alloc] initWithFireDate:d interval:1.0 target:self selector:@selector(timedRefresh:) userInfo:nil repeats:YES];
    
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer:refreshTimer forMode:NSDefaultRunLoopMode];
    } else {
        DDLogVerbose(@"wasn't nil!");
    }
    
}

- (void) stopRefresh {
    [refreshTimer invalidate];
    refreshTimer = nil;
}

- (void) timedRefresh:(NSTimer *)aTimer {
    self.allPeripherals = [NSArray arrayWithArray:[[BLEManager singleton] allPeripherals]];
    self.allDescs = [NSArray arrayWithArray:[[BLEManager singleton] allDescs]];
    //NSLog(@"here they are: %@", self.allPeripherals);
    
    
    DDLogVerbose(@"here they are:");
    for(NSDictionary *dict in self.allDescs) {
        DDLogVerbose(@"%@ %d", [dict objectForKey:@"Name"], [[dict objectForKey:@"RSSI"] intValue]);
    }
    
    
    [leTableView reloadData];
}


#pragma mark - Peripheral Communication

- (void) newPeripheralNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"NewPeripheral"]) {
        DDLogInfo(@"found new peripheral!");
        self.allPeripherals = [NSArray arrayWithArray:[[BLEManager singleton] allPeripherals]];
        self.allDescs = [NSArray arrayWithArray:[[BLEManager singleton] allDescs]];
        //NSLog(@"here they are: %@", self.allDescs);
        
        /*
         NSLog(@"here they are:");
         for(NSDictionary *dict in self.allDescs) {
         NSLog(@"%@ %d", [dict objectForKey:@"Name"], [[dict objectForKey:@"RSSI"] intValue]);
         }
         */
        
        [leTableView reloadData];
    }
    
}

- (void) receivedDataNow {
    [self stopRefresh];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - IBActions

- (IBAction) cancelPressed:(id)sender {
    DDLogInfo(@"cancel pressed");
    [self stopRefresh];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) segmentChosen:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    DDLogInfo(@"segment chosen: %d", selectedSegment);
    
    // 0: Any
    // 1: KST
    // 2: Dr. Kroll
    // 3: RedBear
    
    [[BLEManager singleton] setSelectedShield:[NSNumber numberWithInt:selectedSegment]];
    
}

- (IBAction) connectPressed:(id)sender {
    DDLogInfo(@"connect pressed");
    if([self.allDescs count] == 0) return;
    if(selectedCell == 99) return;
    if(connectButton.enabled == YES) [self startToConnect];
}

- (IBAction) disconnectPressed:(id)sender {
    DDLogInfo(@"disconnect pressed");
    if([self.allDescs count] == 0) return;
    if(disconnectButton.enabled == YES) {
        self.justTheDiscButton = YES;
        [self startToDisconnect];
    }
}


#pragma mark - Funcs

- (void) startToConnect {
    [activityInd startAnimating];
    [[BLEManager singleton] connectToPeripheral:selectedCell];
    [self stopRefresh];
}

- (void) startToDisconnect {
    [activityInd stopAnimating];
    [[BLEManager singleton] disconnect];
    //[self stopRefresh];
    connectButton.enabled = YES;
    [connectButton setAlpha:1.0];
    disconnectButton.enabled = NO;
    [disconnectButton setAlpha:0.6];
    selectedCell = 99;
    //refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timedRefresh:) userInfo:nil repeats:YES];
    [self startRefresh];
    [leTableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if([self.allDescs count] > 0) return [self.allDescs count];
    
    return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    [cell.textLabel setIsAccessibilityElement:NO];
    [cell.detailTextLabel setIsAccessibilityElement:NO];
    
    if([self.allDescs count] > 0) {
        
        NSDictionary *desc = [self.allDescs objectAtIndex:[indexPath row]];
        NSString *pName = [desc objectForKey:@"Name"];
        NSNumber *pRSSI = [desc objectForKey:@"RSSI"];
        NSDate *pDate = [desc objectForKey:@"LastAdvert"];
        
        NSString *title = [NSString stringWithFormat:@"%@ %ddBm", pName, [pRSSI intValue]];
        [cell.textLabel setText:title];
        
        
        NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *components = [calendar components:kCFCalendarUnitMinute|kCFCalendarUnitSecond
                                                   fromDate:pDate
                                                     toDate:[NSDate date]
                                                    options:0];
        
        int s = components.second;
        
        NSString *detailText;
        
        //NSLog(@"seconds diff: %d", components.second);
        
        [cell setAccessibilityLabel:[NSString stringWithFormat:@"%@ at %d dBm", pName, [pRSSI intValue]]];
        [cell setAccessibilityHint:@"A found BLE device"];
        
        
        if(s > 10) { // Maybe make this 10s? or 30s? hmm...
            detailText = [NSString stringWithFormat:@"Last advert >10 seconds ago"];
            [cell setAccessibilityValue:@"Last advert was more than 10 seconds ago"];
        } else {
            detailText = [NSString stringWithFormat:@"Last advert: %d seconds ago", s];
            [cell setAccessibilityValue:[NSString stringWithFormat:@"Last advert: %d seconds", s]];
        }
        
        [cell.detailTextLabel setText:detailText];
        
        
    } else {
        
        [cell.textLabel setText:@"No devices found"];
        [cell.detailTextLabel setText:@"Please start your BLE device"];
        
        [cell setAccessibilityLabel:@"No devices found"];
        [cell setAccessibilityHint:@"BLE devices that are started will appear here"];
        
    }
    
    if(selectedCell == [indexPath row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if([self.allDescs count] > 0) {
        selectedCell = [indexPath row];
        [leTableView reloadData];
        connectButton.enabled = YES;
        [connectButton setAlpha:1.0];
    }
    
}

@end
