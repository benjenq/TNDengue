//
//  APIResourceRow.m
//  TNDengue
//
//  Created by benejnq on 2015/10/26.
//
//

#import "APIResourceRow.h"
#import "DBHelper.h"
@implementation APIResourceRow
@synthesize ResourceTitle = _ResourceTitle, ResourceDate = _ResourceDate, ResourceID = _ResourceID;
@synthesize type = _type;
@synthesize isReceive = _isReceive;


-(instancetype)init{
    self = [super init];
    if (self) {
        self.ResourceTitle = self.ResourceID = [[NSString alloc] initWithString:@""];
        self.type = ReSourceTypeAllDays;
        self.isReceive = NO;
    }
    return self;
}

-(instancetype)initWithTitle:(NSString *)inTitle{
    
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *database = [dbh openDatabase];
    sqlite3_stmt *stm;
    
    NSString *l_str = @" SELECT ResourceTitle , ResourceDate, ResourceID, type ,isReceive FROM APIResource WHERE ResourceTitle = ? ";
    
    self = [self init];
    @try{
        if(sqlite3_prepare_v2(database, [l_str UTF8String], -1, &stm, NULL)== SQLITE_OK) {
            sqlite3_bind_text(stm,1,[inTitle UTF8String],-1,SQLITE_STATIC);
            while(sqlite3_step(stm) ==SQLITE_ROW){

                self.ResourceTitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 0)];
                self.ResourceDate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 1)];
                self.ResourceID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 2)];
                self.type = (ReSourceType)sqlite3_column_int(stm, 3);
                self.isReceive = (BOOL)sqlite3_column_int(stm, 4);
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
    NSUInteger rows = [DBHelper intForSQL:[[NSString stringWithFormat:@"SELECT COUNT(*) FROM APIResource WHERE ResourceTitle = '%@' ;", self.ResourceTitle] UTF8String]];
    if (rows >= 1) {
        return [self updateRec];
        
    }
    else
    {
        return [self addRec];
    }
}

-(BOOL)addRec{
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *database = [dbh openDatabase];
    sqlite3_stmt *stm;
    BOOL successInsData = NO;
    @try{
        NSString *l_str = @"INSERT INTO APIResource(ResourceTitle,ResourceDate,ResourceID,type,isReceive) VALUES(?,?,?,?,?) ; ";
        const char *sql = [l_str UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)== SQLITE_OK) {
            sqlite3_bind_text(stm,1,[self.ResourceTitle UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,2,[self.ResourceDate UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,3,[self.ResourceID UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_int(stm,4,(int)self.type);
            sqlite3_bind_int(stm,5,(int)self.isReceive);
            
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
        NSString *l_str = @"UPDATE  APIResource SET ResourceDate = ?, ResourceID = ?, type = ? ,isReceive = ? WHERE ResourceTitle = ? ; ";
        const char *sql = [l_str UTF8String];
        if(sqlite3_prepare_v2(database, sql, -1, &stm, NULL)== SQLITE_OK) {
            
            sqlite3_bind_text(stm,1,[self.ResourceDate UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,2,[self.ResourceID UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_int(stm,3,(int)self.type);
            sqlite3_bind_int(stm,4,(int)self.isReceive);
            sqlite3_bind_text(stm,5,[self.ResourceTitle UTF8String],-1,SQLITE_STATIC);
            
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
    return [DBHelper executeSQL:"DELETE FROM APIResource ;"];
}

-(void)dealloc{
    //NSLog(@"<%p> %@(%@:%@) dealloc", self,[[self class] description],self.ResourceTitle,self.ResourceID);
    [super dealloc];
}


@end
