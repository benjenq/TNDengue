//
//  TNDengueMapViewController.h
//  TNDengue
//
//  Created by benejnq on 2015/10/6.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TNDengueMapViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>{
    IBOutlet MKMapView *_mapview;
    BOOL _isLoadFinish;
    
    CLLocationManager *_locationManager;
    
    IBOutlet UISearchBar *_searchbar;
}

@end
