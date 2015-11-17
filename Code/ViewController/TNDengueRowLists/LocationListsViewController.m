//
//  LocationListsViewController.m
//  TNDengue
//
//  Created by benejnq on 2015/10/27.
//
//

#import "LocationListsViewController.h"
#import "TNDengueRow.h"
#import "DBHelper.h"
@implementation LocationListsViewController

-(instancetype)initWithidx:(NSInteger)inIndex{
    self = [super initWithNibName:[[self class] description] bundle:nil];
    if (self) {
        [self renewArrayWithIndex:inIndex];
    }
    
    return self;
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [_tableV setDataSource:(id<UITableViewDataSource>)self];
    [_tableV setDelegate:(id<UITableViewDelegate>)self];
    
    self.title = @"通報紀錄";
    
}

-(void)renewArrayWithIndex:(NSInteger)inIndex{
    if (!_TNDengueArray) {
        _TNDengueArray = [[NSMutableArray alloc] init];
    }
    else
    {
        [_TNDengueArray removeAllObjects];
    }
    
    //取得座標
    
    TNDengueRow *rec = [[TNDengueRow alloc] initWithidx:inIndex];
    
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *database = [dbh openDatabase];
    sqlite3_stmt *stm;
    
    NSString *l_str = @" SELECT idx FROM TNDengueRow WHERE longitude = ? AND latitude = ? ORDER BY confirmDate DESC,idx DESC ; ";
    
    @try{
        if(sqlite3_prepare_v2(database, [l_str UTF8String], -1, &stm, NULL)== SQLITE_OK) {
            sqlite3_bind_double(stm,1,(float)rec.longitude);
            sqlite3_bind_double(stm,2,(float)rec.latitude);
            
            while(sqlite3_step(stm) ==SQLITE_ROW){
                NSInteger _idx = (NSInteger)sqlite3_column_int(stm, 0);
                TNDengueRow *tmpRec = [[TNDengueRow alloc] initWithidx:_idx];
                [_TNDengueArray addObject:tmpRec];
                [tmpRec release];
            }
        }
    }@catch (id exception) {
    }@finally {
        // 關閉敘述
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    
    [rec release];
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _TNDengueArray.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    TNDengueRow *tmpRec = [_TNDengueArray objectAtIndex:indexPath.row];
    
    NSString *cdate = [tmpRec.confirmDate stringByReplacingOccurrencesOfString:@"T00:00:00" withString:@""];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ , %@",tmpRec.roadname,cdate];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"(No.%@) %@, %@ (%.5f,%.5f)",tmpRec.seqno,tmpRec.village,tmpRec.area,tmpRec.latitude,tmpRec.longitude];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    //NSLog(@"<%p> %@ dealloc", self,[[self class] description]);
    _tableV.delegate = nil;
    _tableV.dataSource = nil;
    [_tableV removeFromSuperview];
    
    [_TNDengueArray removeAllObjects];
    [_TNDengueArray release];
    
    [super dealloc];
}


@end
