//
//  BLEChooserViewController.h
//  RoboBrrd Interact
//
//  Created by Erin Kennedy on 13-01-29.
//  Copyright (c) 2013 Erin Kennedy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDLog.h"

@interface BLEChooserViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    // -- view -- //
    UITableView *leTableView;
    UIActivityIndicatorView *activityInd;
    UIButton *connectButton;
    UIButton *disconnectButton;
    IBOutlet UISegmentedControl *shieldSegment;
    
    // -- data -- //
    NSArray *allPeripherals;
    NSArray *allDescs;
    NSTimer *refreshTimer;
    int selectedCell;
    BOOL justTheDiscButton;
    
}

@property (nonatomic, retain) IBOutlet UITableView *leTableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityInd;
@property (nonatomic, retain) IBOutlet UIButton *connectButton;
@property (nonatomic, retain) IBOutlet UIButton *disconnectButton;
@property (nonatomic, retain) IBOutlet UISegmentedControl *shieldSegment;

@property (nonatomic, retain) NSArray *allPeripherals;
@property (nonatomic, retain) NSArray *allDescs;
@property (nonatomic, retain) NSTimer *refreshTimer;

@property (assign) BOOL justTheDiscButton;

// -- view -- //
- (IBAction) cancelPressed:(id)sender;
- (IBAction) segmentChosen:(id)sender;
- (IBAction) connectPressed:(id)sender;
- (IBAction) disconnectPressed:(id)sender;

// -- funcs -- //
- (void) startToConnect;
- (void) startToDisconnect;

- (void) startRefresh;
- (void) stopRefresh;

- (void) receivedDataNow;

@end
