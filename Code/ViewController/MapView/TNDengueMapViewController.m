//
//  TNDengueMapViewController.m
//  TNDengue
//
//  Created by benejnq on 2015/10/6.
//
//

#import "TNDengueMapViewController.h"
#import "tndAnnotation.h"

#import "DBHelper.h"
#import "TNDengueRow.h"

#import "CHTAddrViewController.h"
#import "CHTAddrRow.h"

#import "LocationListsViewController.h"

#import "MBProgressHUD.h"

@interface TNDengueMapViewController()<MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
}


@end

@implementation TNDengueMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_searchbar setDelegate:(id<UISearchBarDelegate>)self];
    [_searchbar setAlpha:0.7];
    _searchbar.placeholder = NSLocalizedString(@"SearchBarPlaceHolder", @"Search text ...");
    
    [_mapview setDelegate:(id<MKMapViewDelegate>)self];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeAll;
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    self.title = @"疫情分佈";

    _isLoadFinish = NO;
    
    //設定起始範圍
    MKCoordinateRegion theRegion;
    
    //set region center
    CLLocationCoordinate2D theCenter;
    theCenter.latitude = 23.66276688;
    theCenter.longitude = 120.96791950;
    theRegion.center=theCenter;
    
    //set zoom level  //4.4065,3.0519
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 4.4065;
    theSpan.longitudeDelta = 3.0519;
    theRegion.span = theSpan;
    
    //set scroll and zoom action
    _mapview.scrollEnabled = YES;
    _mapview.zoomEnabled = YES;
    
    //set map Region
    [_mapview setRegion:theRegion animated:NO];
    
    
   
    
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


- (void)viewWillAppear:(BOOL)animated{
    [self addObserverKeyboardEvent];
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    if (_isLoadFinish) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //設定起始範圍
        MKCoordinateRegion theRegion;
        
        //set region center
        CLLocationCoordinate2D theCenter;
        theCenter.latitude = 22.99208970;
        theCenter.longitude = 120.19948478;
        theRegion.center=theCenter;
        
        //set zoom level
        MKCoordinateSpan theSpan;
        theSpan.latitudeDelta = 0.2922;
        theSpan.longitudeDelta = 0.2442;
        theRegion.span = theSpan;
        
        //set map Region
        [_mapview setRegion:theRegion animated:YES];
        
        
    });
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [_searchbar resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - IBAction

-(IBAction)CHTAddrView:(id)sender{
    CHTAddrViewController *vc = [[CHTAddrViewController alloc] initWithidx:0];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    
}

-(IBAction)ShowLocationOnMap:(id)sender{
    if (![self checkLocationAuthorizationStatus]) {
        return;
    }
    if (!_mapview.showsUserLocation) {
        _mapview.showsUserLocation = YES;
    }
    else
    {
        _mapview.showsUserLocation = NO;
    }
}

-(IBAction)doSearch:(UISearchBar *)sender{
    [_mapview.annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isKindOfClass:[MKUserLocation class]]) {
            return;
        }
        tndAnnotation *ann = (tndAnnotation *)obj;
        if (ann.chtidx >0 ) {
            return;
        }
        
        [_mapview removeAnnotation:obj];
        
    }];
    
    if ([sender.text isEqualToString:@""]) {
        [self startAddPinOnMap:@""];
        return;
    }
    
    NSString *trimmedString = [sender.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *keywords = [trimmedString componentsSeparatedByString:@" "]; // 拆解出個字串
    
    __block NSString *searchString = @""; //一定要給起始值，不然無法進行操作
    
    /*
     for (NSString *keyword in keywords) {
     NSString *whereAndCase = [NSString stringWithFormat:@" AND ((area LIKE '%%%@%%') OR (village LIKE '%%%@%%') OR (roadname LIKE '%%%@%%') OR (confirmDate LIKE '%%%@%%')) ",
     keyword,keyword,keyword,keyword];
     searchString = [searchString stringByAppendingString:whereAndCase];
     }
     */
    
    [keywords enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) { //NSEnumerationReverse:反過來跑
        NSString *keyword = (NSString *)obj;
        NSString *whereAndCase = [NSString stringWithFormat:@" AND ((area LIKE '%%%@%%') OR (village LIKE '%%%@%%') OR (roadname LIKE '%%%@%%') OR (confirmDate LIKE '%%%@%%')) ",
                                  keyword,keyword,keyword,keyword];
        searchString = [[searchString stringByAppendingString:whereAndCase] retain]; //使用 enumerateObjects... 時要加 retain
        
    }];
    
    //NSLog(@"searchString = %@,%lu",searchString,(unsigned long)[searchString retainCount]);
    [self startAddPinOnMap:searchString];
    
}

#pragma mark - Keyboard NSNotification

-(void)keyboardWillShow:(NSNotification *)n{
    
    // get the size of the keyboard
    //CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //NSLog(@"keyboardWillShow:%@",[n userInfo]);
    NSDictionary* userInfo = [n userInfo];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _searchbar.frame = CGRectMake(0, keyboardFrame.origin.y - _searchbar.frame.size.height, _searchbar.frame.size.width, _searchbar.frame.size.height);
    //計算 formScroll frame 的變量，將下緣與KeyBoard上端切齊
    
    
   
    
}
-(void)keyboardDidShow:(NSNotification *)n{
    //NSLog(@"keyboardDidShow:%@",[n userInfo]);
    
    
}
-(void)keyboardWillHide:(NSNotification *)n{
    
    //NSLog(@"keyboardWillHide:%@",[n userInfo]);
    
    NSDictionary* userInfo = [n userInfo];
    
    CGRect keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _searchbar.frame = CGRectMake(0, keyboardFrame.origin.y - _searchbar.frame.size.height, _searchbar.frame.size.width, _searchbar.frame.size.height);
    
}
-(void)keyboardDidHide:(NSNotification *)n{
    //NSLog(@"keyboardDidHide:%@",[n userInfo]);
    
}
#pragma mark - 檢查定位服務狀態
-(BOOL)checkLocationAuthorizationStatus{ //檢查定位服務狀態
    NSUInteger code = [CLLocationManager authorizationStatus];
    if (code == kCLAuthorizationStatusDenied || code == kCLAuthorizationStatusRestricted) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"錯誤"
                                                        message:@"請開啟「隱私權」-「定位服務」"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return NO;
    }
    
    if ([UIDevice isAboveiOS8]) {
        
        if (code == kCLAuthorizationStatusNotDetermined ){ // && ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            if (_locationManager == nil || !_locationManager) {
                _locationManager = [[CLLocationManager alloc] init];
            }
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [_locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [_locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else //iOS 7 以前
    {
        return YES;
    }
    return YES;
    
}

-(void)mapView:(MKMapView *)mapView moveToLocation:(CLLocationCoordinate2D)coordinate animation:(BOOL)animated{
    //設定起始範圍
    MKCoordinateRegion theRegion;
    
    //set region center
    CLLocationCoordinate2D theCenter;
    theCenter.latitude = coordinate.latitude;
    theCenter.longitude = coordinate.longitude;
    theRegion.center=theCenter;
    
    //set zoom level
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.0020;
    theSpan.longitudeDelta = 0.0020;
    theRegion.span = theSpan;
    
    //set map Region
    [mapView setRegion:theRegion animated:animated];
    
}


#pragma mark - AnnotationView 動畫


#pragma mark  開始取得病例座標PIN
-(void)startAddPinOnMap:(NSString *)searchCaseString{
    DBHelper *dbh = [DBHelper shareInstance];
    sqlite3 *database = [dbh openDatabase];
    sqlite3_stmt *stm;
    
    NSString *l_str = [NSString stringWithFormat:@" SELECT idx FROM TNDengueRow WHERE 1=1 %@ ORDER BY idx DESC ; ",searchCaseString];  //roadname
    
    NSInteger annCount = 0;
    
    @try {
        if(sqlite3_prepare_v2(database, [l_str UTF8String], -1, &stm, NULL)== SQLITE_OK) {
            while(sqlite3_step(stm) ==SQLITE_ROW){
                int _idx = (int)sqlite3_column_int(stm, 0);
                TNDengueRow *row = [[TNDengueRow alloc] initWithidx:_idx];
                
                if (row.latitude < -90 || row.latitude > 90) {
                    [row release];
                    continue;
                }
                
                if (row.longitude < -180 || row.longitude > 180) { //經度
                    [row release];
                    continue;
                }
                if (annCount < 1000) {
                    CLLocationCoordinate2D location;
                    location.longitude = row.longitude;
                    location.latitude = row.latitude;
                    tndAnnotation *poi = [[tndAnnotation alloc] initWithCoords:location];
                    NSString *cdate = [row.confirmDate stringByReplacingOccurrencesOfString:@"T00:00:00" withString:@""];
                    poi.title = [NSString stringWithFormat:@"%@，%@",row.roadname,row.village];
                    poi.subtitle = [NSString stringWithFormat:@"%@ (%@)",row.area,cdate];
                    poi.idx = row.idx;
                    [_mapview addAnnotation:(id<MKAnnotation>)poi];
                    [poi release];
                }
                
                [row release];
                
                annCount = annCount +1;
                
            }
        
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    if (HUD == nil || !HUD) {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
    }
    if (self.navigationController) {
        [self.navigationController.view addSubview:HUD];
    }
    else
    {
        [self.view addSubview:HUD];
    }
    NSString *annCountStr = [Utility numberToString:[NSNumber numberWithInteger:annCount]];
    HUD.labelText = [NSString stringWithFormat:NSLocalizedString(@"Receiving Record(s) ...", @"取得 %@ 筆記錄"),annCountStr];
    [HUD show:YES];
    [HUD hide:YES afterDelay:0.8];
    //NSLog(@"取得 %lu 筆資料", (long)annCount);
    
}

-(void)startAddChtPinOnMap{
    DBHelper *dbh = [DBHelper shareInstance];
    sqlite3 *database = [dbh openDatabase];
    sqlite3_stmt *stm;
    
    NSString *l_str = @" SELECT idx FROM CHTAddr ORDER BY idx DESC ; ";
    
    @try {
        if(sqlite3_prepare_v2(database, [l_str UTF8String], -1, &stm, NULL)== SQLITE_OK) {
            
            while(sqlite3_step(stm) ==SQLITE_ROW){
                int _idx = (int)sqlite3_column_int(stm, 0);
                CHTAddrRow *row = [[CHTAddrRow alloc] initWithidx:_idx];
                
                CLLocationCoordinate2D location;
                location.longitude = row.longitude;
                location.latitude = row.latitude;
                tndAnnotation *poi = [[tndAnnotation alloc] initWithCoords:location];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    poi.title = [row.sname stringByAppendingString:@" (可預購 iPhone 6S)"];
                }
                else
                {
                    poi.title = [row.sname stringByAppendingString:@" (可預購)"];
                }
                poi.subtitle = row.address;
                poi.chtidx = (NSUInteger)_idx;
                
                [_mapview addAnnotation:(id<MKAnnotation>)poi];
                [poi release];
                [row release];
                
            }
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    
}


#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    //NSLog(@"%.4f,%.4f",mapView.region.span.latitudeDelta,mapView.region.span.longitudeDelta);
    //NSLog(@"center=%.8f,%.8f",mapView.region.center.latitude,mapView.region.center.longitude);
    if (animated) {
        if (_isLoadFinish) {
            return;
        }
        [self startAddPinOnMap:@""];
        _isLoadFinish = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self startAddChtPinOnMap];
            
            
            
        });
        //NSLog(@"%.4f,%.4f",mapView.region.span.latitudeDelta,mapView.region.span.longitudeDelta);
        //NSLog(@"center=%.8f,%.8f",mapView.region.center.latitude,mapView.region.center.longitude);
        
        
    }
}
#pragma mark - Annotation MKMapViewDelegate
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
    if([annotation isKindOfClass:[MKUserLocation class]]) // && (mapview.userLocationVisible))
    {
        MKUserLocation *annUserLocation = (MKUserLocation *)annotation;
        //NSLog(@"%@",annUserLocation.location);
        [self mapView:mapView moveToLocation:annUserLocation.location.coordinate animation:YES];
        return nil;
    }
    
    
    MKAnnotationView *Annotation = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation1"];
    //MKPinAnnotationView *Annotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation1"]; //iOS 9 Fix
    
    Annotation.canShowCallout=YES;
    Annotation.highlighted=NO;
    [Annotation setSelected:NO animated:NO];
    
    tndAnnotation *poi = (tndAnnotation *)annotation;
    if (poi.chtidx >0) { //中華電信
        //Annotation.animatesDrop = NO; //iOS 9 Fix
        //Annotation.pinColor = MKPinAnnotationColorPurple;
        
        Annotation.image = [UIImage imageNamed:@"chtstore.png"];
        
        // Call out 按鈕
        UIButton *rightbtn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        Annotation.rightCalloutAccessoryView = rightbtn;
        UIImageView *imgv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon_cht.png"]];
        Annotation.leftCalloutAccessoryView = imgv;
        [imgv release];
    }
    else //
    {
        //Annotation.animatesDrop = NO; //iOS 9 Fix
        //Annotation.pinColor = MKPinAnnotationColorRed;
        
        Annotation.image = [UIImage imageNamed:@"flag.png"];
        UIButton *rightbtn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        Annotation.rightCalloutAccessoryView = rightbtn;
    }
    return Annotation;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{

    tndAnnotation *poi = view.annotation;
    if (poi.chtidx >0) {
        CHTAddrViewController *vc = [[CHTAddrViewController alloc] initWithidx:(int)poi.chtidx];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        
    }
    else if (poi.idx >0) {
        LocationListsViewController *vc = [[LocationListsViewController alloc] initWithidx:poi.idx];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];

    }
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    //NSLog(@"searchBarShouldBeginEditing");
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //NSLog(@"searchBarTextDidBeginEditing");
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar setAlpha:1];
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    //NSLog(@"searchBarShouldEndEditing");
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    if ([searchBar.text isEqualToString:@""]) {
        [searchBar setAlpha:0.7];
    }
    return YES;

}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    //NSLog(@"searchBarTextDidEndEditing");
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self doSearch:searchBar];
    //NSLog(@"searchBarSearchButtonClicked:%@",searchBar.text);
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    //NSLog(@"searchBarCancelButtonClicked");
    
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_searchbar removeFromSuperview];
    [_searchbar setDelegate:nil];
    
    if (_mapview.showsUserLocation) {
        _mapview.showsUserLocation = NO;
    }
    if (_locationManager != nil) {
        [_locationManager release];_locationManager = nil;
    }
    [_mapview removeFromSuperview];
    [_mapview release];
    
    NSLog(@"<%p>%@ dealloc",self,[[self class] description]);
    [super dealloc];
}



@end
