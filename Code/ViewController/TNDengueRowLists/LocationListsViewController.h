//
//  LocationListsViewController.h
//  TNDengue
//
//  Created by benejnq on 2015/10/27.
//
//

#import <UIKit/UIKit.h>
@class TNDengueRow;
@interface LocationListsViewController : UIViewController{
    NSMutableArray *_TNDengueArray;
    
    IBOutlet UITableView *_tableV;
}

-(instancetype)initWithidx:(NSInteger)inIndex;

@end
