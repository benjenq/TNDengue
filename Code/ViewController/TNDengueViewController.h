//
//  TNDengueViewController.h
//  TNDengue
//
//  Created by benejnq on 15/9/15.
//  Copyright 2015 benejnq. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TNDengueViewController : UIViewController {
    IBOutlet UILabel *_lblastdt;
    IBOutlet UILabel *_lbtotal;
    IBOutlet UILabel *_lbaddcount;
    
    
    IBOutlet UILabel *_lbaddvillage1;
    IBOutlet UILabel *_lbaddvillage2;

    
    IBOutlet UILabel *_lbaddarea1;
    IBOutlet UILabel *_lbaddarea2;
    IBOutlet UILabel *_lbaddarea3;
    
    IBOutlet UIButton *reloadbtn;
    
    IBOutlet UILabel *_lbDataTitle;
    
    BOOL ishasFinishReceiveTNDengueRows;
    

}

@end
