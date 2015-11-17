//
//  TNDengueRow.m
//  TNDengue
//
//  Created by benejnq on 2015/9/20.
//
//

#import "TNDengueRow.h"
#import "DBHelper.h"
@implementation TNDengueRow
@synthesize seqno = _seqno, village = _village, area = _area, roadname = _roadname, confirmDate = _confirmDate;

@synthesize idx = _idx;
@synthesize longitude = _longitude,latitude = _latitude;

-(instancetype) init{
    self = [super init];
    if (self) {
        self.idx = 0;
        self.seqno = @"0";
        self.village = @"";
        self.area = @"";
        self.roadname = @"";
        self.confirmDate = @"";
        self.longitude = 0;
        self.latitude = 0;
        
    }
    return self;
}

-(instancetype)initWithidx:(NSInteger)widx wSeqNo:(NSString *)wseqNo wVillage:(NSString *)wvillage wArea:(NSString *)warea wRoadname:(NSString *)wroadname wConfirmDate:(NSString *)wconfirmDate wLongitude:(CGFloat)wlongitude wLatitude:(CGFloat)wlatitude{
    self = [super init];
    if (self) {
        self.idx = widx;
        self.seqno = wseqNo;
        self.village = wvillage;
        self.area = warea;
        self.roadname = wroadname;
        self.confirmDate = wconfirmDate;
        self.longitude = wlongitude;
        self.latitude = wlatitude;
        
    }
    return self;
    
}

#pragma mark - 從資料庫讀取

-(instancetype)initWithidx:(NSInteger)idx{
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *database = [dbh openDatabase];
    sqlite3_stmt *stm;
    
    NSString *l_str = @" SELECT idx , seqno, area, village, roadname, confirmDate, longitude, latitude FROM TNDengueRow WHERE idx = ? ";
    
    self = [self init];
    @try{
        if(sqlite3_prepare_v2(database, [l_str UTF8String], -1, &stm, NULL)== SQLITE_OK) {
            sqlite3_bind_int(stm,1,(int)idx);
            while(sqlite3_step(stm) ==SQLITE_ROW){
                self.idx = (NSInteger)sqlite3_column_int(stm, 0);
                self.seqno = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 1)];
                self.area = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 2)];
                self.village = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 3)];
                self.roadname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 4)];
                self.confirmDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 5)];
                self.longitude = (CGFloat)sqlite3_column_double(stm, 6);
                self.latitude = (CGFloat)sqlite3_column_double(stm, 7);
            }
            
        }
    
    
    }@catch (id exception) {
    }@finally {
        // 關閉敘述
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    
    return self;

}

-(BOOL)writeToDB{
    NSUInteger rows = [DBHelper intForSQL:[[NSString stringWithFormat:@"SELECT COUNT(*) FROM TNDengueRow WHERE idx = %li ;", (long)self.idx] UTF8String]];
    if (rows >= 1) {
        return [self updateRec];
        
    }
    else
    {
        return [self addRec];
    }
}

+ (void)BeginTransaction{
    [DBHelper BEGINTRANSACTION];
}
+ (void)EndTransaction{
    [DBHelper ENDTRANSACTION];
}

-(BOOL)addRec{
    
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *database = [dbh openDatabase];
    sqlite3_stmt *stm;
    BOOL successInsData = NO;
    @try{
        NSString *l_str = @"INSERT INTO TNDengueRow(idx,seqno,area,village,roadname,confirmDate,longitude,latitude) \
        VALUES(?,?,?,?,?,?,?,?) ";
        const char *sql = [l_str UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)== SQLITE_OK) {
            
            sqlite3_bind_int(stm,1,(int)self.idx);
            sqlite3_bind_text(stm,2,[self.seqno UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,3,[self.area UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,4,[self.village UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,5,[self.roadname UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,6,[self.confirmDate UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_double(stm, 7, self.longitude);
            sqlite3_bind_double(stm, 8, self.latitude);

            
            if(sqlite3_step(stm) ==SQLITE_DONE){
                successInsData = YES;
            }
        }
    }@catch (id exception) {
    }@finally {
        // 關閉敘述
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    return successInsData;
    
}

-(BOOL)updateRec{
    
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *database = [dbh openDatabase];
    sqlite3_stmt *stm;
    BOOL successInsData = NO;
    @try{
        NSString *l_str = @"UPDATE  TNDengueRow SET seqno = ?, area = ? , village = ? , roadname = ? , confirmDate = ? , longitude = ? , latitude = ? \
        WHERE idx = ? ; ";
        const char *sql = [l_str UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)== SQLITE_OK) {
            
            
            sqlite3_bind_text(stm,1,[self.seqno UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,2,[self.area UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,3,[self.village UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,4,[self.roadname UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,5,[self.confirmDate UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_double(stm, 6, self.longitude);
            sqlite3_bind_double(stm, 7, self.latitude);
            sqlite3_bind_int(stm,8,(int)self.idx);
            
            
            if(sqlite3_step(stm) ==SQLITE_DONE){
                successInsData = YES;
            }
        }
    }@catch (id exception) {
    }@finally {
        // 關閉敘述
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    return successInsData;
    
    
}

+(BOOL)deleteAll{
    return [DBHelper executeSQL:"DELETE FROM TNDengueRow;"];
}


+(NSUInteger)maxidx{
    return [DBHelper intForSQL:"SELECT MAX(idx) AS maxidx FROM TNDengueRow ;"];
    
}

+(NSString *)lastConfirmDate{
    NSUInteger maxidx = [self maxidx];
    TNDengueRow *tmp = [[TNDengueRow alloc] initWithidx:(int)maxidx];
    NSString *result = tmp.confirmDate;
    [tmp release];
    
    return [result stringByReplacingOccurrencesOfString:@"T00:00:00" withString:@""];
    
}

+(NSUInteger)lastAdditionCount{
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS COUNT FROM TNDengueRow WHERE confirmDate like '%@%%' ;",[TNDengueRow lastConfirmDate]];
    
    return [DBHelper intForSQL:[sql UTF8String]];
    
}

+(NSUInteger)lastAdditionVillageCount:(NSString *)invillage{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS COUNT FROM TNDengueRow WHERE confirmDate like '%@%%' AND village LIKE '%%%@%%' ;",[TNDengueRow lastConfirmDate],invillage];
    return [DBHelper intForSQL:[sql UTF8String]];
    
}

+(NSUInteger)totalAdditionVillageCount:(NSString *)invillage{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS COUNT FROM TNDengueRow WHERE village LIKE '%%%@%%' ;",invillage];
    return [DBHelper intForSQL:[sql UTF8String]];
    
}

+(NSUInteger)lastAdditionAreaCount:(NSString *)inarea{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS COUNT FROM TNDengueRow WHERE confirmDate like '%@%%' AND area LIKE '%%%@%%' ;",[TNDengueRow lastConfirmDate],inarea];
    return [DBHelper intForSQL:[sql UTF8String]];
    
}

+(NSUInteger)totalAdditionAreaCount:(NSString *)inarea{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) AS COUNT FROM TNDengueRow WHERE area LIKE '%%%@%%' ;",inarea];
    return [DBHelper intForSQL:[sql UTF8String]];
    
}

-(void)dealloc{
    //NSLog(@"<%p> %@(%@) dealloc", self,[[self class] description],self.seqNo);
    [super dealloc];
}
@end
