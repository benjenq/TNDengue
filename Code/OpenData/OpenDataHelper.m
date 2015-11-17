//
//  getOpenData.m
//  TNDengue
//
//  Created by benejnq on 2015/9/15.
//
//

#import "OpenDataHelper.h"
#import "TNDengueRow.h"
#import "getResource.h"
#import "APIResourceRow.h"

NSString *const tnDataURL  = @"http://data.tainan.gov.tw";
NSString *const APIPath = @"/api/action/datastore_search?limit=2000&resource_id=" ;
//NSString *const resource_id = @"241c4bee-0b80-47bd-8533-ca2adec175ff";

@implementation OpenDataHelper
@synthesize OpenDataQueue;
@synthesize delegate = _delegate;

+(OpenDataHelper *)sharedInstance{
    static OpenDataHelper *theInstance = nil;
    @synchronized(self){	// 避免同步存取
        //if( !theInstance ){
        if( theInstance == nil ){
            theInstance = [[OpenDataHelper alloc] init];
            theInstance.OpenDataQueue = dispatch_queue_create("OpenDataQueue", NULL);
            NSLog(@"getOpenData sharedInstance...");
        }
        [theInstance resetRows];
    }
    
    return theInstance;
}

-(void)resetRows{
    if (!_allTNDengueRows) {
        _allTNDengueRows = [[NSMutableArray alloc] init];
    }
    else
    {
        [_allTNDengueRows removeAllObjects];
    }
}

-(void)startReceiveTNDengueRows{
    //先抓取資料最後一筆
    //NSUInteger maxidx = [TNDengueRow maxidx];
    //NSLog(@"%@",[getResourceID identifier]);
    
    
    //先做"截至
    
    [getResource getResourceArrayFromURL:^(NSArray *APIs) {
        if (APIs == nil || !APIs || APIs.count == 0) {
            NSLog(@"找不到資源 APIs ");
            if ([_delegate respondsToSelector:@selector(receiveTNDengueRowsFailure:)]) {
                [_delegate receiveTNDengueRowsFailure:@"找不到資源 APIs "];
            }
            return ;
        }
        [self resetRows];
        dispatch_async(self.OpenDataQueue, ^{
            [APIs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                APIResourceRow *apiRec = (APIResourceRow *)obj;
                //NSLog(@"apirec:%@,%@,%li",apirec.ResourceTitle,apirec.ResourceID,(long)apirec.type);
                
                if (apiRec.isReceive) {
                    return ;
                }
                
                NSString *APIUrlStr = [NSString stringWithFormat:@"%@%@%@",tnDataURL,APIPath,apiRec.ResourceID];
                
                
                
                [self insertRowFromUrl:APIUrlStr withAPIResourceRow:apiRec];
                //NSLog(@"Url(%i)=%@,%@",apiRec.isReceive,APIUrlStr,apiRec.ResourceTitle);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //apiRec.isReceive = YES;
                    [apiRec writeToDB];
                });
                
                
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self syncToDB];
                [self resetRows];
                if ([_delegate respondsToSelector:@selector(receiveTNDengueRowsCompleted:)]) {
                    [_delegate receiveTNDengueRowsCompleted:YES];
                }
            });
            
        });
    }];
    
    //[self insertRowFromUrl:[tnDataURL stringByAppendingString:[NSString stringWithFormat:@"%@&offset=%lu",[APIPath stringByAppendingString:resource_id],(unsigned long)maxidx]]];
}

-(void)insertRowFromUrl:(NSString *)urlStr withAPIResourceRow:(APIResourceRow *)apiRec{

    NSString *encodeUrl = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *aUrl = [NSURL URLWithString:encodeUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3.0];
    
    //NSURLRequest *request = [NSURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
    //timeoutInterval:3.0];
    [request setHTTPMethod:@"POST"];
    
    NSHTTPURLResponse *response = NULL;
    NSError *error = nil;
    NSData *responseData= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error !=  nil) {
        NSLog(@"error=%@",error);
        return ;
    }
    //NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //NSLog(@"responseStr=%@",responseStr);
    
    //[responseStr release];
    
    NSDictionary *responseDic = [OpenDataHelper responseJsonToDictionary:responseData];
    if (responseDic == nil) {
        return;
    }
    
    //解析
    if ([[responseDic objectForKey:@"success"] boolValue] == YES) {
        //NSLog(@"responseDic=%@",responseDic);
    }
    else
    {
        return;
    }
    
    NSDictionary *result = [responseDic objectForKey:@"result"];
    
    NSString *nextLinkurl = [[result objectForKey:@"_links"] objectForKey:@"next"];
    NSUInteger total = [[result objectForKey:@"total"] integerValue];
    
    __block BOOL doNextlink = YES;
    NSArray *records = [result objectForKey:@"records"];
    if (records.count == 0) {
        doNextlink = NO;
    }
    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *rec = (NSDictionary *)obj;
        
        TNDengueRow *row = [[TNDengueRow alloc] init];
        
        NSInteger _id = [self nullInteger:[rec objectForKey:@"_id"]] ;
        
        //row.idx = (int)[[rec objectForKey:@"_id"] integerValue];
        
        
        if (apiRec.type == ReSourceTypeAllDays) { // 截至OOXX
            row.idx = _id;
            row.seqno = [self nullString:[rec objectForKey:@"編號"]];
        }
        else  //每日單日
        {
            row.idx = -1 ;
            row.seqno = [NSString stringWithFormat:@"%li",(long)row.idx];
        }
        
        row.village = [rec objectForKey:@"里別"];
        if (row.village != (NSString *)[NSNull null]) {
            row.village = [row.village stringByReplacingOccurrencesOfString:@"　" withString:@""];
            [row.village stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        row.area = [rec objectForKey:@"區別"];
        if (row.area != (NSString *)[NSNull null]) {
            row.area = [row.area stringByReplacingOccurrencesOfString:@"　" withString:@""];
            [row.area stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        row.roadname = [rec objectForKey:@"道路名稱"];
        if (row.roadname != (NSString *)[NSNull null]) {
            row.roadname = [row.roadname stringByReplacingOccurrencesOfString:@"　" withString:@""];
            [row.roadname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        row.confirmDate = [rec objectForKey:@"確診日"];
        row.longitude = [self nullFloat:[rec objectForKey:@"經度座標"]] ;
        row.latitude = [self nullFloat:[rec objectForKey:@"緯度座標"]];
        
        if (row.latitude > 90 ) {  // 有些資料的經緯度相反了
            CGFloat tmplatitude = row.latitude ;
            row.latitude = row.longitude;
            row.longitude = tmplatitude;
        }
        
        if (_id >= total) {
            doNextlink = NO;
        }
        
        if (row.seqno != (NSString *)[NSNull null]) {
            [_allTNDengueRows addObject:row];
        }
        
        if ([_delegate respondsToSelector:@selector(atTNDengueRow:total:withTitle:)]) {
            [_delegate atTNDengueRow:(NSUInteger)row.idx total:(NSUInteger)total withTitle:apiRec.ResourceTitle];
        }
        
        //NSLog(@"%li,%@,%@,%@,%@,%@,%f,%f",(long)row.idx,row.seqno,row.village,row.area,row.roadname,row.confirmDate,row.longitude,row.latitude);
        
        [row release];
        apiRec.isReceive = YES;
    }];
    
    if (doNextlink) {
        //NSLog(@"%@",nextLinkurl);
        [self insertRowFromUrl:[tnDataURL stringByAppendingString:nextLinkurl] withAPIResourceRow:apiRec];
    }
    
}

-(NSInteger)nullInteger:(id)integerVal{
    if (integerVal == [NSNull null]) {
        return 0;
    }
    if (integerVal == nil) {
        return 0;
    }
    return (NSInteger)[integerVal integerValue];
}

-(CGFloat)nullFloat:(id)floatVal{
    if (floatVal == [NSNull null]) {
        return 0;
    }
    if (floatVal == nil) {
        return 0;
    }
    return (CGFloat)[floatVal floatValue];
}

-(NSString *)nullString:(id)str{
    if (str == [NSNull null]) {
        return @"";
    }
    if (str == nil) {
        return @"";
    }
    return (NSString *)str;
}

-(void)syncToDB{
    
    [TNDengueRow BeginTransaction];
    [_allTNDengueRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[TNDengueRow class]]) {
            TNDengueRow *rec = (TNDengueRow *)obj;
            if (rec.idx == -1) {
                rec.idx = [TNDengueRow maxidx] +1;
                rec.seqno = [NSString stringWithFormat:@"%li",(long)rec.idx];
            }
            //NSLog(@"%li,%@,%@,%@,%@,%@,%f,%f",(long)rec.idx,rec.seqno,rec.village,rec.area,rec.roadname,rec.confirmDate,rec.longitude,rec.latitude);
            [rec writeToDB];
        }
        
    }];
    [TNDengueRow EndTransaction];
    
    
}

+(NSDictionary *)responseJsonToDictionary:(NSData *)responseData{
    NSError *error;
    NSDictionary* jsondic = [NSJSONSerialization
                             JSONObjectWithData:responseData
                             options:kNilOptions
                             error:&error];
    if ([jsondic isKindOfClass:[NSDictionary class]] ) {
        NSDictionary *Result = jsondic;
        
        return Result;
    }
    return nil;
}

@end


