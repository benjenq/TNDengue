//
//  CHTAddrViewController.h
//  TNDengue
//
//  Created by benejnq on 2015/10/6.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface CHTAddrViewController : UIViewController{
    NSUInteger _idx;
    IBOutlet UIScrollView *formScroll;
    CGPoint currentEditTextFiledPoint;
    
    CGRect formScrollOriginalFrame;
    UITextField *currentEditTextField;
    
    IBOutlet UITextField *tf_sname;
    IBOutlet UITextField *tf_address;
    IBOutlet UITextField *tf_telno;
    IBOutlet UITextField *tf_worktime;
    IBOutlet UITextView *tf_remark;
    
    IBOutlet UILabel *lb_coord; //座標
    
    IBOutlet UIButton *btnEdit;
    IBOutlet UIButton *btnDel;
    
    CLLocationCoordinate2D _coords;
    
}

-(instancetype)initWithidx:(int)inidx;

@end
