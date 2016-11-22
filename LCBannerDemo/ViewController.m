//
//  ViewController.m
//  LCBannerDemo
//
//  Created by lcc on 16/6/27.
//  Copyright © 2016年 early bird international. All rights reserved.
//

#import "ViewController.h"
#import "LCBannerScrollerView.h"

@interface ViewController ()<LCBannerScrollerViewDelegate>

@property (nonatomic,strong) NSArray *imageArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _imageArray = [NSArray arrayWithObjects:@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",nil];
    LCBannerScrollerView *bannerScrollView = [[LCBannerScrollerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 250)];
    bannerScrollView.delegate = self;
    [self.view addSubview:bannerScrollView];
    
    [bannerScrollView startLoopScroll];
}

#pragma -mark- bannerScrollView 代理
- (NSInteger )bannerView:(LCBannerScrollerView *)bannerScrollView{

    return _imageArray.count;
}

- (NSString *)bannerLinks:(LCBannerScrollerView *)bannerScrollView linkForIndexOfBanner:(NSInteger)indexPath{

    return _imageArray[indexPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
