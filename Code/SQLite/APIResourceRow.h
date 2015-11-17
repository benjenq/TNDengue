//
//  APIResourceRow.h
//  TNDengue
//
//  Created by benejnq on 2015/10/26.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,ReSourceType)
{
    ReSourceTypeAllDays = 0,
    ReSourceTypeDay = 1,
};

@interface APIResourceRow : NSObject{
    NSString *_ResourceTitle;
    NSString *_ResourceDate;
    NSString *_ResourceID;
    ReSourceType _type;
    BOOL _isReceive;

    
}

@property (nonatomic,retain) NSString *ResourceTitle , *ResourceDate, *ResourceID ;
@property (nonatomic) ReSourceType type;
@property (nonatomic) BOOL isReceive;

-(instancetype)initWithTitle:(NSString *)inTitle;

-(BOOL)writeToDB;

+(BOOL)deleteAll;

@end
