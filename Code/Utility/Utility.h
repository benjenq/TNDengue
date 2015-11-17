//
//  Utility.h
//  TNDengue
//
//  Created by benejnq on 2015/9/16.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
extern NSString *const DataTitle;
@interface Utility : NSObject

+(NSString *)GetBundlePath;
+(NSString *)GetDocumentPath;
+(NSString *)GetCachePath;
+(NSString *)GettmpPath;


+(BOOL)fileisExist:(NSString *)filePath;
+(BOOL)copyfile:(NSString *)source toPath:(NSString *)destination;

#pragma mark - 數字文字轉換
+(NSString *)numberToString:(NSNumber *)val;
+(NSNumber *)stringToNumber:(NSString *)valStr;

@end

@interface UIDevice (netWorStatus)

+(NetworkStatus)netWorStatus;

+(BOOL)isAboveiOS8;

@end
