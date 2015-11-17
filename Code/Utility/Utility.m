//
//  Utility.m
//  TNDengue
//
//  Created by benejnq on 2015/9/16.
//
//

#import "Utility.h"

NSString *const DataTitle  = @"DataTitle";
@implementation Utility

+(NSString *)GetBundlePath{
    return [[NSBundle mainBundle] bundlePath];
}

+(NSString *)GetDocumentPath{
    return [NSString stringWithFormat:@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]];
}
+(NSString *)GetCachePath{
    return [NSString stringWithFormat:@"%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0]];
}
+(NSString *)GettmpPath{
    return [NSString stringWithFormat:@"%@",NSTemporaryDirectory()];
}

+(BOOL)fileisExist:(NSString *)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
        return YES;
    else
        return NO;
}

+(BOOL)copyfile:(NSString *)source toPath:(NSString *)destination{
    if (![self fileisExist:source]) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL success = [fileManager copyItemAtPath:source toPath:destination error:&error];
    if (error != nil) {
        NSLog(@"copyfile error:%@",[error description]);
        
    }
    return success;
    
}
#pragma mark - 數字文字轉換
+(NSString *)numberToString:(NSNumber *)val{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,###,###,##0.#########"];
    
    NSString *formattedNumberString = [numberFormatter stringFromNumber:val];
    [numberFormatter release];
    return formattedNumberString;
}
+(NSNumber *)stringToNumber:(NSString *)valStr{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,###,###,##0.#########"];
    
    NSNumber *formattedNumber = [numberFormatter numberFromString:valStr];
    [numberFormatter release];
    return formattedNumber;
}


@end

@implementation UIDevice (netWorStatus)

+(NetworkStatus)netWorStatus{
    Reachability *wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
    //[wifiReach startNotifier];
    Reachability *internetReach = [[Reachability reachabilityForInternetConnection] retain];
    //[internetReach startNotifier];
    
    NetworkStatus wifiStatus = [wifiReach currentReachabilityStatus];
    NetworkStatus internetStatus = [internetReach currentReachabilityStatus];
    
    if(wifiStatus != NotReachable)
        return (NetworkStatus)ReachableViaWiFi;
    else if((wifiStatus == NotReachable) && (internetStatus == NotReachable))
        return (NetworkStatus)NotReachable;
    else if((wifiStatus == NotReachable) && (internetStatus != NotReachable))
        return (NetworkStatus)ReachableViaWWAN;
    else
        return (int)9;
}

+(BOOL)isAboveiOS8{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"8.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending) {
        // OS version >= 8.0
        return YES;
        
    }
    else {
        // OS version < 8.0
        return NO;
    }
}


@end
