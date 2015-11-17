//
//  CHTAddrRow.h
//  TNDengue
//
//  Created by benejnq on 2015/10/6.
//
//

#import <Foundation/Foundation.h>

@interface CHTAddrRow : NSObject{
    int _idx; //_id
    NSString *_sname; //門市名
    NSString *_address; //地址
    NSString *_telno; //電話
    NSString *_worktime; //上班時間
    CGFloat _longitude; //經度座標
    CGFloat _latitude; //緯度座標
    NSString *_remark; //備註
}

@property (nonatomic,retain) NSString *sname, *address, *telno, *worktime, *remark;
@property (nonatomic) int idx;
@property (nonatomic) CGFloat longitude,latitude;

#pragma mark - 從資料庫讀取
-(instancetype)initWithidx:(int)idx;

+(NSUInteger)maxidx;

-(BOOL)addRec;
-(BOOL)updateRec;
-(BOOL)deleteRec;


@end
