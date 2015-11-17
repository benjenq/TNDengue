//
//  CHTAddrRow.m
//  TNDengue
//
//  Created by benejnq on 2015/10/6.
//
//

#import "CHTAddrRow.h"
#import "DBHelper.h"

@implementation CHTAddrRow
@synthesize sname = _sname, address = _address, telno = _telno, worktime = _worktime, remark = _remark;
@synthesize idx = _idx;
@synthesize longitude = _longitude,latitude = _latitude;

-(instancetype)initWithidx:(int)idx{
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *database = [dbh openDatabase];
    sqlite3_stmt *stm;
    
    NSString *l_str = @" SELECT idx , sname, address, telno, worktime, longitude, latitude ,remark FROM CHTAddr WHERE idx = ? ";
    
    self = [self init];
    self.sname = self.address = self.telno = self.worktime = self.remark = @"";
    self.idx = 0;
    self.latitude = self.longitude = 0;
    
    @try{
        if(sqlite3_prepare_v2(database, [l_str UTF8String], -1, &stm, NULL)== SQLITE_OK) {
            sqlite3_bind_int(stm,1,(int)idx);
            while(sqlite3_step(stm) ==SQLITE_ROW){
                self.idx = (int)sqlite3_column_int(stm, 0);
                self.sname = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 1)];
                self.address = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 2)];
                self.telno = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 3)];
                self.worktime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 4)];
                self.longitude = (CGFloat)sqlite3_column_double(stm, 5);
                self.latitude = (CGFloat)sqlite3_column_double(stm, 6);
                self.remark = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 7)];

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

+(NSUInteger)maxidx{
    return [DBHelper intForSQL:"SELECT MAX(idx) AS maxidx FROM CHTAddr ;"];
    
}

-(BOOL)addRec{
    
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *database = [dbh openDatabase];
    sqlite3_stmt *stm;
    BOOL successInsData = NO;
    @try{
        NSString *l_str = @"INSERT INTO CHTAddr(idx,sname,address,telno,worktime,longitude,latitude,remark) \
        VALUES(?,?,?,?,?,?,?,?) ";
        const char *sql = [l_str UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)== SQLITE_OK) {
            
            sqlite3_bind_int(stm,1,(int)self.idx);
            sqlite3_bind_text(stm,2,[self.sname UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,3,[self.address UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,4,[self.telno UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,5,[self.worktime UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_double(stm, 6, self.longitude);
            sqlite3_bind_double(stm, 7, self.latitude);
            sqlite3_bind_text(stm,8,[self.remark UTF8String],-1,SQLITE_STATIC);
            
            
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
        NSString *l_str = @"UPDATE CHTAddr SET sname = ?, address = ? , telno = ? , worktime = ? , longitude = ? , latitude = ? , remark = ?  \
        WHERE idx = ? ; ";
        const char *sql = [l_str UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)== SQLITE_OK) {
            
            
            sqlite3_bind_text(stm,1,[self.sname UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,2,[self.address UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,3,[self.telno UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,4,[self.worktime UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_double(stm, 5, self.longitude);
            sqlite3_bind_double(stm, 6, self.latitude);
            sqlite3_bind_text(stm,7,[self.remark UTF8String],-1,SQLITE_STATIC);
            
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

-(BOOL)deleteRec{
    
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *database = [dbh openDatabase];
    sqlite3_stmt *stm;
    BOOL successDelData = NO;
    @try{
        NSString *l_str = @"DELETE FROM CHTAddr WHERE idx = ? ; ";
        const char *sql = [l_str UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)== SQLITE_OK) {
            
            sqlite3_bind_int(stm,1,(int)self.idx);
            
            if(sqlite3_step(stm) ==SQLITE_DONE){
                successDelData = YES;
            }
        }
    }@catch (id exception) {
    }@finally {
        // 關閉敘述
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    return successDelData;
    
    
}

-(void)dealloc{
    [super dealloc];
}



@end
