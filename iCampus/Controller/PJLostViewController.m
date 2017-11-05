//
//  PJLostViewController.m
//  iCampus
//
//  Created by #incloud on 2017/5/1.
//  Copyright © 2017年 ifLab. All rights reserved.
//

#import "PJLostViewController.h"
#import "PJNewLostViewController.h"
#import "PJLostTableView.h"
#import "ICNetworkManager.h"
#import "IDMPhotoBrowser.h"
#import "YZLostDetailsViewController.h"

@interface PJLostViewController () <PJLostTableViewDelegate,IDMPhotoBrowserDelegate>
@property (nonatomic, strong) PJNewLostViewController *vc;
@end

@implementation PJLostViewController
{
    PJLostTableView *_kTableView;
    NSMutableArray *_freshData;
    int page;
    NSString *_freshFlag;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self performSelector:@selector(CreatPublishBtn) withObject:nil afterDelay:0.5];
}

//- (PJNewLostViewController*)vc {
//    if (!_vc) {
//
//    }
//    return _vc;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated {
    [PJHUD dismiss];
}

- (void)initView {
    page = 0;
    _freshFlag = headerRefresh;
    _freshData = [[NSMutableArray alloc]init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"失物招领";
    UIStoryboard *SB = [UIStoryboard storyboardWithName:@"PJNewLost" bundle:nil];
    _vc = [SB instantiateViewControllerWithIdentifier:@"PJNewLostViewController"];
    
    UIBarButtonItem* backBtn = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backBtn;
    
    _kTableView = [PJLostTableView new];
    [self.view addSubview:_kTableView];
    _kTableView.tableDelegate = self;
    _kTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headfresh)];
    _kTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footfresh)];
    [self getDataFromHttp];
}

- (void)CreatPublishBtn{
    _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_publishBtn setImage:[UIImage imageNamed:@"publish"] forState:UIControlStateNormal];
    _publishBtn.frame = CGRectMake(SCREEN_WIDTH-60, SCREEN_HEIGHT-130, 50, 50);
    [_publishBtn setAlpha:0.0f];
    [_publishBtn addTarget:self action:@selector(nextItemClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_publishBtn];
    
    CGAffineTransform transform =CGAffineTransformRotate(_publishBtn.transform,-M_PI);
    [UIView animateWithDuration:0.5 animations:^{
        [_publishBtn setTransform:transform];
        [_publishBtn setAlpha:1.0f];
    }];
}

- (void)nextItemClick {
    self.vc.hidesBottomBarWhenPushed = YES;
    if ([self.navigationController.topViewController isKindOfClass:[PJLostViewController class]]) {
        [self.navigationController pushViewController:_vc animated:YES];
    }
}

- (void)getDataFromHttp {
    [PJHUD showWithStatus:@""];
    NSDictionary *paramters = @{@"offset":@(page*10),
                                @"filter":@"isFound=false"};
    [[ICNetworkManager defaultManager] GET:@"Lost"
                                parameters:paramters
                                   success:^(NSDictionary *dic) {
                                       [_kTableView.mj_header endRefreshing];
                                       [_kTableView.mj_footer endRefreshing];
                                       [PJHUD dismiss];
                                       NSArray *data = dic[@"resource"];
                                       _freshData = (NSMutableArray*)[_freshData arrayByAddingObjectsFromArray:data];
                                       if (data.count) {
                                           if ([_freshFlag isEqualToString:headerRefresh]) {
                                               [_kTableView.dataArr removeAllObjects];
                                               _freshData = [data mutableCopy];
                                           }
                                           _kTableView.dataArr = [_freshData mutableCopy];
                                       } else {
                                           [PJHUD showErrorWithStatus:@"没有数据了"];
                                       }
                                      
                                   }
                                   failure:^(NSError *error) {
                                       NSLog(@"error:%@",error);
                                       // error信息要怎么处理？
                                   }];
}

- (void)headfresh {
    page = 0;
    _freshFlag = headerRefresh;
    [self getDataFromHttp];
}

- (void)footfresh {
    page ++;
    _freshFlag = footerRefresh;
    [self getDataFromHttp];
}

- (void)tableViewClick:(NSArray *)data index:(NSInteger)index {
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:data];
    browser.delegate = self;
    browser.displayToolbar = NO;
    browser.displayDoneButton = NO;
    browser.dismissOnTouch = YES;
    [browser setInitialPageIndex:index - 100];
    [self presentViewController:browser animated:YES completion:nil];
}

- (void)tableViewClickToDetails:(NSDictionary *)data{
    YZLostDetailsViewController* vc = [[YZLostDetailsViewController alloc]init];
    vc.dataSource = data;
    vc.returnblock = ^{
        [self getDataFromHttp];
    };
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableViewMove:(BOOL)hidden{
    UIView *tab = self.tabBarController.view;
    CGRect  tabRect=self.tabBarController.tabBar.frame;
    if ([tab.subviews count] < 2) {
        return;
    }
    
    UIView *view;
    if ([[tab.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
        view = [tab.subviews objectAtIndex:1];
    } else {
        view = [tab.subviews objectAtIndex:0];
    }
    
    if (hidden) {
        view.frame = tab.bounds;
        tabRect.origin.y=[[UIScreen mainScreen] bounds].size.height+self.tabBarController.tabBar.frame.size.height;
    } else {
        view.frame = CGRectMake(tab.bounds.origin.x, tab.bounds.origin.y, tab.bounds.size.width, tab.bounds.size.height);
        tabRect.origin.y=[[UIScreen mainScreen] bounds].size.height-self.tabBarController.tabBar.frame.size.height;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        self.tabBarController.tabBar.frame=tabRect;
    }completion:^(BOOL finished) {
        
    }];
}

@end
