//
//  tndAnnotation.m
//  TNDengue
//
//  Created by benejnq on 2015/10/6.
//
//

#import "tndAnnotation.h"

@implementation tndAnnotation

-(id)initWithCoords:(CLLocationCoordinate2D)coords{
    self = [super init];
    if (self != nil) {
        self.coordinate = coords;
        self.title = @"";
        self.subtitle = @"";
        self.chtidx = 0;
        self.idx = 0;
    }
    
    return self;
}

@end
