//
//  ViewController.m
//  PWResumeDowloadTool2
//
//  Created by Tony_Zhao on 4/22/15.
//  Copyright (c) 2015 TonyZPW. All rights reserved.
//

#import "ViewController.h"
#import "PWDownloader.h"
#import "PWDownloadModel.h"
#import "DownloadTableViewCell.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView registerClass:[DownloadTableViewCell class] forCellReuseIdentifier:@"Cell"];
    NSArray *urls = @[
//                      @"http://qd.baidupcs.com/file/6b3102395c675e941c09d55ed30b148f?bkt=p2-qd-138&fid=386762388-250528-872077811561546&time=1429968750&sign=FDTAXERLBH-DCb740ccc5511e5e8fedcff06b081203-TNnXxq1OndO7JWELGBrVxPMlkRc%3D&to=qb&fm=Qin,B,T,t&newver=1&newfm=1&flow_ver=3&sl=78118991&expires=8h&rt=pr&r=112385314&mlogid=3075145501&vuk=386762388&vbdid=3403389969&fin=iOS%20Core%20Animation%20Advanced%20Techniques_20150110065530.pdf&fn=iOS%20Core%20Animation%20Advanced%20Techniques_20150110065530.pdf&slt=pm&uta=0"
//                      ,
                      @"http://images.gadmin.st.s3.amazonaws.com/n49487/images/buehne/image2.jpeg"
//                      ,
//                      @"http://www.designsnext.com/wp-content/uploads/2014/04/nature-wallpapers-16.jpg"
//                      ,
//                      @"http://finalmile.in/behaviourarchitecture/wp-content/uploads/2013/04/forces-of-nature-wallpaper.jpg"
//                      ,
//                      @"http://images2.fanpop.com/images/photos/4800000/Beauty-of-nature-random-4884759-1280-800.jpg"
//                      ,
//                      @"http://3.bp.blogspot.com/-0K132QvQ1D8/UVknJpBvxbI/AAAAAAAAGMI/ZtFyefyHJac/s1600/Beautiful-Nature-+wallpaper.jpg"
//                      ,
//                      @"http://datastore04.rediff.com/h1500-w1500/thumb/5A5A5B5B4F5C1E5255605568365E655A63672A606D6C/0upnd2vwarhp3y9i.D.0.Copy-of-Nature-Wallpapers-9.jpg"
                      ];
    
    
    
    NSMutableArray *mtArray = [NSMutableArray array];
    for (NSString *url in urls) {
        
//        [[PWDownloader sharedDownloader] addItemToDownloadFrom:[NSURL URLWithString:url] withCompletionBlock:^{
//            
////            NSLog(@"%@ end", url);
//            
//        } startImmediately:YES];
        PWDownloadModel *model = [[PWDownloadModel alloc] initWithURL:[NSURL URLWithString:url] complete:nil fail:nil];
        [mtArray addObject:model];
        
    }
    
    self.dataList = [mtArray copy];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellID = @"Cell";
      DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    
    cell.downloadModel = self.dataList[indexPath.row];
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

@end
