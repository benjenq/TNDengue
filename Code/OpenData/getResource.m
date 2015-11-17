//
//  getResourceid.m
//  TNDengue
//
//  Created by benejnq on 2015/10/4.
//
//

#import "getResource.h"
#import "TFHpple.h"
#import "APIResourceRow.h"
#import "DBHelper.h"
#import "OpenDataHelper.h"
NSString *const dataURL  = @"http://data.tainan.gov.tw";
@implementation getResource


+(void)getResourceArrayFromURL:(void(^)(NSArray *APIs))completion{
    NSString *htmlString=[NSString stringWithContentsOfURL:[NSURL URLWithString:[dataURL stringByAppendingString:@"/dataset/denguefevercases"]]
                                                  encoding: NSUTF8StringEncoding error:nil];
    //NSLog(@"htmlString = %@",htmlString);
    NSData *htmlData=[htmlString dataUsingEncoding:NSUTF8StringEncoding];
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//div[@class='module-content']/section[@id='dataset-resources']/ul[@class='resource-list']/li"]; // get the title
    
    NSMutableArray *APIitemsArray = [[NSMutableArray alloc] init];
    
    for (TFHppleElement *element in elements)
    {
        //NSLog(@"element=%@",[element children]);
        //NSLog(@"element.nodeChildArray=%@",[element objectForKey:@"nodeChildArray"]);
        //NSLog(@"element.text=%@",[element text]);
        //NSLog(@"element.firstChild.content=%@",[[element firstChild] content]);
        //NSLog(@"element.firstChild.content=%@",[element.children objectAtIndex:0]);
        
        //NSLog(@"element ALL Key: %@",[[element attributes] allKeys]);
        //for (id object in [[element attributes] allKeys]) {
        
        //NSLog(@"key=%@,Value=%@",object,[element objectForKey:object]);
        //}
        NSString *dataid = [element objectForKey:@"data-id"];
        if (element.hasChildren) {
            //NSLog(@"data-id=%@,%i",dataid,element.hasChildren);
            for (TFHppleElement *children in element.children){

                for (id object in [[children attributes] allKeys]) {
                    
                    if ([object isEqualToString:@"title"]) {
                        //NSLog(@"key=%@,Value=%@",object,[children objectForKey:object]);
                        NSString *title = [children objectForKey:object];
                        if (!title || title == nil || [title isEqualToString:@""]) {
                            continue;
                        }
                        if ( [title rangeOfString:@"登革熱病例數--"].length > 0  ) {
                            
                            APIResourceRow *apirec = [[APIResourceRow alloc] initWithTitle:title];
                            
                            if ([apirec.ResourceTitle isEqualToString:@""]) {
                                apirec.ResourceTitle = title;
                                
                                NSRange dateRange = [title rangeOfString:@"201"];
                                if (dateRange.location > 0) {
                                    apirec.ResourceDate = [title substringWithRange:NSMakeRange(dateRange.location, 10)];
                                }
                                else
                                {
                                    apirec.ResourceDate = @"";
                                }
                                
                                apirec.ResourceID = dataid; //[element objectForKey:@"data-id"];
                                if ([title rangeOfString:@"登革熱病例數--截至2015/09/30"].length > 0) {
                                    apirec.type = ReSourceTypeAllDays;
                                }
                                else
                                {
                                    apirec.type = ReSourceTypeDay;
                                }
                                apirec.isReceive = NO;
                            }
                            [APIitemsArray addObject:apirec];
                            [apirec release];
                            //[(Dictionary *)APIitems setObject:dataid forKey:title];
                            
                        }
                    }
                }
            }
        }
    }
    [xpathParser release];
    __block BOOL _success = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (APIitemsArray.count > 0) {;
            [APIitemsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                APIResourceRow *apirec = (APIResourceRow *)obj;
                [apirec writeToDB];
                _success = YES;
                
            }];
        }
        [APIitemsArray removeAllObjects];
        [APIitemsArray release];
        
        NSArray *apis = [self APIitemsArray];
        completion(apis);
    });

}

+(NSArray *)APIitemsArray{
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    
    DBHelper *dbh= [DBHelper shareInstance];
    sqlite3 *database = [dbh openDatabase];
    sqlite3_stmt *stm;
    
    NSString *l_str = @" SELECT ResourceTitle FROM APIResource ORDER BY ResourceDate,type, ResourceTitle ;  ";
    
    @try{
        if(sqlite3_prepare_v2(database, [l_str UTF8String], -1, &stm, NULL)== SQLITE_OK) {
            while(sqlite3_step(stm) ==SQLITE_ROW){
                
                NSString *_title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 0)];
                APIResourceRow *apirec = [[APIResourceRow alloc] initWithTitle:_title];
                [itemsArray addObject:apirec];
                [apirec release];
                
            }
            
        }
        
        
    }@catch (id exception) {
    }@finally {
        // 關閉敘述
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    
    NSArray *array;
    if (itemsArray.count > 0) {
        array = [NSArray arrayWithArray:itemsArray];
    }
    else
    {
        array = nil;
    }
    [itemsArray removeAllObjects];
    [itemsArray release];
    
    //NSLog(@"Array=%@",array);
    return array;

}

+(NSString *)dataUrl{
    return dataURL;
}

@end
