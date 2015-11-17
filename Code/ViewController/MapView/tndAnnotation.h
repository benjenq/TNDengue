//
//  tndAnnotation.h
//  TNDengue
//
//  Created by benejnq on 2015/10/6.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface tndAnnotation : NSObject{
    

}
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *subtitle;
@property (nonatomic) NSUInteger chtidx;
@property (nonatomic) NSUInteger idx;

-(id) initWithCoords:(CLLocationCoordinate2D) coords;

@end
