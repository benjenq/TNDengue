//
//  getResourceid.h
//  TNDengue
//
//  Created by benejnq on 2015/10/4.
//
//

#import <Foundation/Foundation.h>

@interface getResource : NSObject


+(void)getResourceArrayFromURL:(void(^)(NSArray *APIs))completion;

+(NSArray *)APIitemsArray;

+(NSString *)dataUrl;

@end
