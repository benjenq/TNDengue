//
//  CHTAddrViewController.m
//  TNDengue
//
//  Created by benejnq on 2015/10/6.
//
//

#import "CHTAddrViewController.h"
#import "CHTAddrRow.h"
#import <CoreLocation/CLLocation.h>

@implementation CHTAddrViewController

-(instancetype)initWithidx:(int)inidx{
    self = [super initWithNibName:[[self class] description] bundle:nil];
    if (self) {
        _idx = (NSUInteger)inidx;
        _coords.latitude = 0;
        _coords.longitude = 0;
        
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
    [tf_address setDelegate:(id<UITextFieldDelegate>)self];
    
    if (_idx > 0) {
        [self bindCHTAddrData:(int)_idx];
        [btnEdit setTitle:@"修改" forState:UIControlStateNormal];
        [btnDel setHidden:NO];
    }
    else
    {
        [btnEdit setTitle:@"新增" forState:UIControlStateNormal];
        [btnDel setHidden:YES];

    }
    
    self.title = @"門市資料";

}

-(void)bindCHTAddrData:(int)inidx{
    if (inidx <= 0 ) {
        return;
    }
    CHTAddrRow *row = [[CHTAddrRow alloc] initWithidx:inidx];
    tf_sname.text = row.sname;
    tf_address.text = row.address;
    tf_telno.text = row.telno;
    tf_worktime.text = row.worktime;
    tf_remark.text = row.remark;
    
    _coords.latitude = row.latitude;
    _coords.longitude = row.longitude;
    lb_coord.text = [NSString stringWithFormat:@"%.4f, %.4f",_coords.latitude,_coords.longitude];
}


-(void)viewWillAppear:(BOOL)animated{
    formScroll.contentSize = formScroll.frame.size;
    formScrollOriginalFrame = formScroll.frame;

    [self addObserverKeyboardEvent];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self resignKeyboardFirst:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)addObserverKeyboardEvent{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
}
#pragma mark - IBAction

-(IBAction)EditRec:(id)sender{
    if ([tf_sname.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"錯誤" message:@"門市名稱必填" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [tf_sname becomeFirstResponder];
        return;
    }
    if (_coords.latitude == 0 || _coords.longitude == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"錯誤" message:@"地址無法對應座標" delegate:nil cancelButtonTitle:@"確定" otherButtonTitles:nil];
        [alert show];
        [alert release];
        [tf_address becomeFirstResponder];
        return;
    }
    CHTAddrRow *row = [[CHTAddrRow alloc] initWithidx:(int)_idx];
    if (_idx <= 0) {
        row.idx = (int)[CHTAddrRow maxidx]+1;
        row.sname = tf_sname.text;
        row.address = tf_address.text;
        row.telno = tf_telno.text;
        row.worktime = tf_worktime.text;
        row.remark = tf_remark.text;
        row.latitude = _coords.latitude;
        row.longitude = _coords.longitude;
        
        [row addRec];
        [row release];
    }
    else
    {
        row.sname = tf_sname.text;
        row.address = tf_address.text;
        row.telno = tf_telno.text;
        row.worktime = tf_worktime.text;
        row.remark = tf_remark.text;
        row.latitude = _coords.latitude;
        row.longitude = _coords.longitude;
        
        [row updateRec];
        [row release];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(IBAction)DeleteRec:(id)sender{
    if (_idx <= 0) {
        return;
    }
    CHTAddrRow *row = [[CHTAddrRow alloc] initWithidx:(int)_idx];
    [row deleteRec];
    [row release];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Keyboard NSNotification

-(void)keyboardWillShow:(NSNotification *)n{
    
    // get the size of the keyboard
    //CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //NSLog(@"keyboardWillShow:%@",[n userInfo]);
    NSDictionary* userInfo = [n userInfo];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //計算 formScroll frame 的變量，將下緣與KeyBoard上端切齊
    
    CGPoint ScrollLowBoundPoint = [self.view convertPoint:CGPointMake(formScrollOriginalFrame.origin.x, formScrollOriginalFrame.origin.y + formScrollOriginalFrame.size.height) //selv.view 上的 frame
                                                   toView:self.view.window];
    CGFloat scrollcuthigh = ScrollLowBoundPoint.y - keyboardFrame.origin.y;
    if (scrollcuthigh >0) {
        [formScroll setFrame:CGRectMake(formScrollOriginalFrame.origin.x, formScrollOriginalFrame.origin.y,
                                        formScrollOriginalFrame.size.width, formScrollOriginalFrame.size.height - scrollcuthigh)];
        
    }
    //iOS 5,6
    if (currentEditTextField) {
        CGPoint textField_xy = [formScroll convertPoint:currentEditTextField.frame.origin toView:self.view.window];
        currentEditTextFiledPoint = CGPointMake(textField_xy.x, textField_xy.y + currentEditTextField.frame.size.height + 8);
        
        CGFloat move_y = currentEditTextFiledPoint.y -  keyboardFrame.origin.y;
        if (move_y > 0) {
            [formScroll setContentOffset:CGPointMake(0, move_y) animated:YES];
        }
        
        [currentEditTextField becomeFirstResponder];
    }
    
}
-(void)keyboardDidShow:(NSNotification *)n{
    //NSLog(@"keyboardDidShow:%@",[n userInfo]);
    
    
}
-(void)keyboardWillHide:(NSNotification *)n{
    
    [formScroll setFrame:formScrollOriginalFrame];
    [formScroll setContentOffset:CGPointZero animated:YES];
    currentEditTextField = nil;
    //[formScroll setContentSize:formScrollOriginalContentSize];
    
    //NSLog(@"keyboardWillHide:%@",[n userInfo]);
}
-(void)keyboardDidHide:(NSNotification *)n{
    //NSLog(@"keyboardDidHide:%@",[n userInfo]);
    
}



-(IBAction)resignKeyboardFirst:(id)sender{
    [tf_sname resignFirstResponder];
    [tf_address resignFirstResponder];
    [tf_telno resignFirstResponder];
    [tf_worktime resignFirstResponder];
    [tf_remark resignFirstResponder];
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (![textField isEqual:tf_address]) {
        return;
    }
    //NSLog(@"textFieldDidEndEditing:%@",textField.text);

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    _coords.latitude = 0;
    _coords.longitude = 0;
    lb_coord.text = [NSString stringWithFormat:@"%.4f, %.4f",_coords.latitude,_coords.longitude];
    [geocoder geocodeAddressString:tf_address.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error:%@",error);
            return ;
        }
        for (CLPlacemark* aPlacemark in placemarks)
        {
            // Process the placemark.
            _coords.latitude = aPlacemark.location.coordinate.latitude;
            _coords.longitude = aPlacemark.location.coordinate.longitude;
            
            lb_coord.text = [NSString stringWithFormat:@"%.4f, %.4f",_coords.latitude,_coords.longitude];
            
        }
        
        
        
    }];
    
    
}

-(void)dealloc{
    NSLog(@"<%p>%@ dealloc",self,[[self class] description]);
    [super dealloc];
}

@end
