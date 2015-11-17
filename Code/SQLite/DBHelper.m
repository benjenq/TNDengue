//
//  DBHelper.m
//  TNDengue
//
//  Created by benejnq on 2015/9/16.
//
//

#import "DBHelper.h"

@interface DBHelper()

@property (nonatomic,retain) NSString *databasePath;
@end

@implementation DBHelper
@synthesize database;

+ (DBHelper *) shareInstance{
    // Singleton
    static DBHelper *theInstance;
    @synchronized(self){
        if( !theInstance ){
            theInstance = [[DBHelper alloc] init];
            theInstance.databasePath = [DBHelper dbPath];
            if (![Utility fileisExist:theInstance.databasePath]) {
                BOOL success = [Utility copyfile:[[Utility GetBundlePath] stringByAppendingPathComponent:DATABASE_FILENAME]
                                          toPath:theInstance.databasePath];
                if (!success) {
                    return nil;
                }
            }
        }
        
        [theInstance openDatabase];
        
    }
    return theInstance;
    
    
}

- (sqlite3 *) openDatabase{
    if(!database){
        self.databasePath = [DBHelper dbPath];
        if(sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK) {
            NSLog(@"Opening database [%@]...",DATABASE_FILENAME);
            return database;
        }else{
            return nil;
        }
    }else{
        //NSLog(@"Return database ...");
        return database;
    }
}

+ (void)BEGINTRANSACTION{
    [[DBHelper shareInstance] BEGINTRANSACTION];
}
+ (void)ENDTRANSACTION{
    [[DBHelper shareInstance] ENDTRANSACTION];
}

- (void)BEGINTRANSACTION{
    char *ERROR;
    if (sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, &ERROR)!=SQLITE_OK){
        NSLog(@"ERROR:BEGIN TRANSACTION");
    }
}

- (void)ENDTRANSACTION{
    char *ERROR;
    if (sqlite3_exec(database, "END TRANSACTION", NULL, NULL, &ERROR)!=SQLITE_OK){
        NSLog(@"ERROR:END TRANSACTION");
    }
}



+(NSString *)dbPath{
    NSString *dbName = DATABASE_FILENAME;
    //return [[Utility GetBundlePath] stringByAppendingPathComponent:dbName];
    return [[Utility GetDocumentPath] stringByAppendingPathComponent:dbName];
}

// 關閉資料庫
- (void) closeDatabase
{
    if(database){
        NSLog(@"close Database ...");
        sqlite3_close(database);
        database = nil;
    }
}

// 資料總數
+ (NSUInteger) intForSQL:(const char *) sql{
    return (NSUInteger)[[DBHelper shareInstance] intForSQL:sql];
}

- (int) intForSQL:(const char *) sql
{
    sqlite3_stmt *stm;
    int count = 0;
    @try{
        if(sqlite3_prepare_v2(database,sql,-1,&stm,NULL) == SQLITE_OK) {
            if( sqlite3_step(stm)==SQLITE_ROW ){
                count = sqlite3_column_int(stm,0);
            }
        }
    }@catch(id exception){
    }@finally {
        // 釋放敘述
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    return count;
}

+ (NSString *) stringFromSQL:(const char *) sql{
    return (NSString *)[[DBHelper shareInstance] stringFromSQL:sql];
}

- (NSString *) stringFromSQL:(const char *) sql{
    
    sqlite3_stmt *stm;
    NSString *str = @"";
    @try{
        if(sqlite3_prepare_v2(database,sql,-1,&stm,NULL) == SQLITE_OK) {
            if( sqlite3_step(stm)==SQLITE_ROW ){
                str = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 0)];
            }
        }
    }@catch(id exception){
    }@finally {
        // 釋放敘述
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    return str;
    
}

+ (BOOL)executeSQL:(const char *)sql{
    return [[DBHelper shareInstance] executeSQL:sql];
}

// 執行SQL語法
- (BOOL)executeSQL:(const char *)sql{
    sqlite3_stmt *stm;
    BOOL isExecSuccess = NO;
    @try{
        if(sqlite3_prepare_v2(database,sql,-1,&stm,NULL) == SQLITE_OK) {
            if(sqlite3_step(stm) ==SQLITE_DONE){
                isExecSuccess = YES;
            }
        }
    }@catch(id exception){
    }@finally {
        // 釋放敘述
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    return isExecSuccess;
}

@end
