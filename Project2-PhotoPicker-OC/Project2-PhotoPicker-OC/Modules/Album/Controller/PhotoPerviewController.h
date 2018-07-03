//
//  PhotoPerviewController.h
//  Project2-PhotoPicker-OC
//
//  Created by YangJing on 2018/3/19.
//  Copyright © 2018年 YangJing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPerviewController : UIViewController

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableArray *selectArray;

@property (nonatomic, assign) NSInteger currentIndex;

@end
