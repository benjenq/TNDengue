//
//  getOpenData.h
//  TNDengue
//
//  Created by benejnq on 2015/9/15.
//
//

#import <Foundation/Foundation.h>
//extern NSString *const tnDataURL;
@protocol OpenDataHelperDelegate;
@interface OpenDataHelper : NSObject{
    NSMutableArray *_allTNDengueRows;
    
    id <OpenDataHelperDelegate> _delegate;
    
}

@property (nonatomic) dispatch_queue_t OpenDataQueue;
@property (nonatomic,retain) id <OpenDataHelperDelegate> delegate;

+(OpenDataHelper *)sharedInstance;

-(void)startReceiveTNDengueRows;

@end

@protocol OpenDataHelperDelegate <NSObject>

-(void)atTNDengueRow:(NSUInteger)currentidx total:(NSUInteger)total withTitle:(NSString *)title;

-(void)receiveTNDengueRowsCompleted:(BOOL)completed;
-(void)receiveTNDengueRowsFailure:(NSString *)errorString;

@end
