//
//  PJBusDetailsTableView.h
//  iCampus
//
//  Created by #incloud on 2017/4/29.
//  Copyright © 2017年 ifLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PJBusDetailsTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataArr;

@end