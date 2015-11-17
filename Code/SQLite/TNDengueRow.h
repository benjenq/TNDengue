//
//  TNDengueRow.h
//  TNDengue
//
//  Created by benejnq on 2015/9/20.
//
//

#import <Foundation/Foundation.h>

@interface TNDengueRow : NSObject{
    NSInteger _idx; //_id
    NSString *_seqno; //編號
    NSString *_village; //里別
    NSString *_area; //區別
    NSString *_roadname; //道路名稱
    NSString *_confirmDate; //確診日
    CGFloat _longitude; //經度座標
    CGFloat _latitude; //緯度座標
    
}

@property (nonatomic,retain) NSString *seqno, *village, *area, *roadname, *confirmDate;
@property (nonatomic) NSInteger idx;
@property (nonatomic) CGFloat longitude,latitude;

-(instancetype)initWithidx:(NSInteger)widx wSeqNo:(NSString *)wseqno wVillage:(NSString *)wvillage wArea:(NSString *)warea wRoadname:(NSString *)wroadname wConfirmDate:(NSString *)wconfirmDate wLongitude:(CGFloat)wlongitude wLatitude:(CGFloat)wlatitude;

#pragma mark - 從資料庫讀取
-(instancetype)initWithidx:(NSInteger)idx;

-(BOOL)writeToDB;

+ (void)BeginTransaction;
+ (void)EndTransaction;

+(BOOL)deleteAll;

+(NSUInteger)maxidx;

+(NSString *)lastConfirmDate;

+(NSUInteger)lastAdditionCount;

+(NSUInteger)lastAdditionVillageCount:(NSString *)invillage;
+(NSUInteger)totalAdditionVillageCount:(NSString *)invillage;

+(NSUInteger)lastAdditionAreaCount:(NSString *)inarea;
+(NSUInteger)totalAdditionAreaCount:(NSString *)inarea;

@end
