//
//  LCBannerScrollerView.h
//  GreatChef
//
//  Created by lcc on 16/3/30.
//  Copyright © 2016年 early bird international. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LCBannerScrollerView;

@protocol LCBannerScrollerViewDelegate <NSObject,UITableViewDelegate>

- (NSInteger )bannerView:(LCBannerScrollerView *)bannerScrollView;

- (NSString *)bannerLinks:(LCBannerScrollerView *)bannerScrollView linkForIndexOfBanner:(NSInteger)indexPath;

@optional
//相应广告图的点击事件
- (void)bannerView:(LCBannerScrollerView *)bannerScrollView didClicked:(NSInteger)index;

@end


@interface LCBannerScrollerView : UIView

@property (nonatomic,strong) NSArray *imageLinksArray;

@property (nonatomic,assign) id <LCBannerScrollerViewDelegate> delegate;

@property (nonatomic,strong) UIColor *barViewColor;

//@property (nonatomic,strong) NSArray *localImgArray;

- (void)reloadBannerScrollerView;

- (void)startLoopScroll;

@end
