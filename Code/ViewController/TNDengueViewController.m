//
//  TNDengueViewController.m
//  TNDengue
//
//  Created by benejnq on 15/9/15.
//  Copyright 2015 benejnq. All rights reserved.
//

#import "TNDengueViewController.h"
#import "OpenDataHelper.h"
#import "TNDengueRow.h"
#import "APIResourceRow.h"
#import "getResource.h"

#import "MBProgressHUD.h"

#import "TNDengueMapViewController.h"

@interface TNDengueViewController()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
}


@end

@implementation TNDengueViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    ishasFinishReceiveTNDengueRows = NO;
    [[OpenDataHelper sharedInstance] setDelegate:(id<OpenDataHelperDelegate>)self];
    
    self.title = NSLocalizedString(@"TNDengueViewControllerTitle", @"台南登革熱");
    
    reloadbtn.titleLabel.numberOfLines = 1;
    reloadbtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    reloadbtn.titleLabel.lineBreakMode = NSLineBreakByClipping; //<-- MAGIC LINE

}
- (void)viewWillAppear:(BOOL)animated{
    if (ishasFinishReceiveTNDengueRows) {
        return;
    }
    [self doReceiveTNDengueRows];
}

- (void)viewDidAppear:(BOOL)animated{
    
    
    
    
}

-(void)doReceiveTNDengueRows{
    if ([UIDevice netWorStatus] == NotReachable) {
        [self renewViewAllData];
        return;
    }
    
    if (HUD == nil || !HUD) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
    }
    [self.navigationController.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Receiving TNDengue Data ...", @"Receiving TNDengue Data ...");
    HUD.removeFromSuperViewOnHide = YES;
    
    [HUD show:YES];
    
    dispatch_async([OpenDataHelper sharedInstance].OpenDataQueue, ^{
        [[OpenDataHelper sharedInstance] startReceiveTNDengueRows];
    });
    
    
    /*
    [HUD showAnimated:YES whileExecutingBlock:^{
        [[OpenDataHelper sharedInstance] startReceiveTNDengueRows];
    }  onQueue:[OpenDataHelper sharedInstance].OpenDataQueue completionBlock:^{
        //[HUD hide:YES];
        [HUD removeFromSuperview];
        [HUD release];
        HUD = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self renewViewAllData];
            [reloadbtn setTitle:@"重新讀取" forState:UIControlStateNormal];
            ishasFinishReceiveTNDengueRows = YES;
        });
    }];
    */
    
    
    
}

-(void)renewViewAllData{
    _lblastdt.text = [TNDengueRow lastConfirmDate];
    
    NSNumber *maxidx = [NSNumber numberWithUnsignedInteger:[TNDengueRow maxidx]];
    _lbtotal.text = [Utility numberToString:maxidx];
    
    NSNumber *lastadd = [NSNumber numberWithUnsignedInteger:[TNDengueRow lastAdditionCount]];
    _lbaddcount.text = [Utility numberToString:lastadd];
    
    
    //忠孝里
    NSNumber *lastcount = [NSNumber numberWithUnsignedInteger:[TNDengueRow lastAdditionVillageCount:@"忠孝里"]];
    NSNumber *totalcount = [NSNumber numberWithUnsignedInteger:[TNDengueRow totalAdditionVillageCount:@"忠孝里"]];
    _lbaddvillage1.text = [[[Utility numberToString:lastcount] stringByAppendingString:@"/"] stringByAppendingString:[Utility numberToString:totalcount]];
    
    //龍山里
    lastcount = [NSNumber numberWithUnsignedInteger:[TNDengueRow lastAdditionVillageCount:@"龍山里"]];
    totalcount = [NSNumber numberWithUnsignedInteger:[TNDengueRow totalAdditionVillageCount:@"龍山里"]];
    _lbaddvillage2.text = [[[Utility numberToString:lastcount] stringByAppendingString:@"/"] stringByAppendingString:[Utility numberToString:totalcount]];
    

    
    //東區
    lastcount = [NSNumber numberWithUnsignedInteger:[TNDengueRow lastAdditionAreaCount:@"東區"]];
    totalcount = [NSNumber numberWithUnsignedInteger:[TNDengueRow totalAdditionAreaCount:@"東區"]];
    _lbaddarea1.text = [[[Utility numberToString:lastcount] stringByAppendingString:@"/"] stringByAppendingString:[Utility numberToString:totalcount]];
    
    //中西區
    lastcount = [NSNumber numberWithUnsignedInteger:[TNDengueRow lastAdditionAreaCount:@"中西區"]];
    totalcount = [NSNumber numberWithUnsignedInteger:[TNDengueRow totalAdditionAreaCount:@"中西區"]];
    _lbaddarea2.text = [[[Utility numberToString:lastcount] stringByAppendingString:@"/"] stringByAppendingString:[Utility numberToString:totalcount]];
    
    //北區
    lastcount = [NSNumber numberWithUnsignedInteger:[TNDengueRow lastAdditionAreaCount:@"北區"]];
    totalcount = [NSNumber numberWithUnsignedInteger:[TNDengueRow totalAdditionAreaCount:@"北區"]];
    _lbaddarea3.text = [[[Utility numberToString:lastcount] stringByAppendingString:@"/"] stringByAppendingString:[Utility numberToString:totalcount]];
    
    

}

-(IBAction)reloadTNDengueRows:(UIButton *)sender{
    if ([UIDevice netWorStatus] == NotReachable) {
        [self renewViewAllData];
        return;
    }
    [APIResourceRow deleteAll];
    [TNDengueRow deleteAll];
    [self renewViewAllData];
    _lblastdt.text = @"2000-01-01";
    _lbDataTitle.text = @"";
    [self doReceiveTNDengueRows];
    
}

-(IBAction)goToMap:(id)sender{
    TNDengueMapViewController *vc = [[TNDengueMapViewController alloc] initWithNibName:[[TNDengueMapViewController class] description] bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    
}

-(IBAction)goToDengueURL:(id)sender{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[getResource dataUrl]]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[getResource dataUrl]]];
    }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark - OpenDataHelperDelegate

-(void)atTNDengueRow:(NSUInteger)currentidx total:(NSUInteger)total withTitle:(NSString *)title{
    dispatch_async(dispatch_get_main_queue(), ^{
        //[UIView setAnimationsEnabled:NO];
        [reloadbtn setTitle:[NSString stringWithFormat:@"%lu/%lu",(unsigned long)currentidx,(unsigned long)total] forState:UIControlStateNormal];
        //[reloadbtn layoutIfNeeded];
        [reloadbtn setNeedsDisplay];
        _lbDataTitle.text = title;
        //[UIView setAnimationsEnabled:YES];
        if (currentidx >= total) {
            
            [reloadbtn setTitle:[NSString stringWithFormat:@"%lu 筆資料重整中...",(unsigned long)total] forState:UIControlStateNormal];
        }
    });
}

-(void)receiveTNDengueRowsCompleted:(BOOL)completed{
    [HUD hide:YES];
    [self renewViewAllData];
    [reloadbtn setTitle:@"重新讀取" forState:UIControlStateNormal];
    ishasFinishReceiveTNDengueRows = YES;
}

-(void)receiveTNDengueRowsFailure:(NSString *)errorString{
    dispatch_async(dispatch_get_main_queue(), ^{
        _lbDataTitle.text = errorString;
        [HUD hide:YES];
    });
}



#pragma mark -

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    //NSLog(@"<%p> %@ dealloc", self,[[self class] description]);
    [super dealloc];
}


@end
