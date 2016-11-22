//
//  LCBannerScrollerView.m
//  GreatChef
//
//  Created by lcc on 16/3/30.
//  Copyright © 2016年 early bird international. All rights reserved.
//

#import "LCBannerScrollerView.h"

#define AnimotionTime 3
#define ScrollTime 1
#define BarViewHeight 4
#define barViewColor [UIColor blackColor]
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface LCBannerScrollerView()<UIScrollViewDelegate>

@property (nonatomic,strong) NSMutableArray *bannerViewArray;
@property (nonatomic,strong) NSMutableArray *bottomViewArray;
@property (nonatomic,weak) UIScrollView *bannerScrollView;
@property (nonatomic,weak) UIView *actionBarView;
@property (nonatomic,assign) int index;
@property (nonatomic,weak) NSTimer *timer;
//改变底部滑条的bool
@property (nonatomic,assign) BOOL isChangeActionBarFrame;

@property (nonatomic,assign) BOOL isDraging;

@end

@implementation LCBannerScrollerView

- (void)creatView{
    
    //初始化数据
    self.index = 0;
    self.isChangeActionBarFrame = YES;
    
    NSInteger bannerNum = [self.delegate bannerView:self];

    UIScrollView *banerScrollerView = [[UIScrollView alloc]init];
    banerScrollerView.frame = CGRectMake(0, 0,self.frame.size.width, self.frame.size.height-BarViewHeight);
    banerScrollerView.contentSize = CGSizeMake(self.frame.size.width * (bannerNum+2), 0);
    [self addSubview:banerScrollerView];
    self.bannerScrollView = banerScrollerView;
    
    banerScrollerView.pagingEnabled = YES;
    banerScrollerView.bounces = NO;
    banerScrollerView.delegate = self;
    banerScrollerView.scrollsToTop = NO;
    banerScrollerView.showsHorizontalScrollIndicator = NO;
    
    //创建广告图
    CGFloat img_x = 0;
    CGFloat img_y = 0;

    CGFloat img_w = SCREEN_WIDTH;
    CGFloat img_h = self.frame.size.height - BarViewHeight;
    
    for (int i = 0; i<bannerNum; i++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(img_x, img_y, img_w, img_h);
        [button addTarget:self action:@selector(bannerTouch:) forControlEvents:UIControlEventTouchUpInside];
//        [button addTarget:self action:@selector(bannerTouchBegin:) forControlEvents:UIControlEventTouchDragInside];
        NSString *imageLink = [self.delegate bannerLinks:self linkForIndexOfBanner:i];
        
        [button setBackgroundImage:[UIImage imageNamed:imageLink] forState:UIControlStateNormal];
        button.contentMode = UIViewContentModeCenter;
        
        button.tag = i;
        [banerScrollerView addSubview:button];
        [self.bannerViewArray addObject:button];
        
        img_x += img_w;
    }
    
    //在首尾各添加一个滚动视图
    for (UIButton *button in self.bannerViewArray) {
        
        CGRect frame = button.frame;
        frame.origin.x = frame.origin.x + frame.size.width;
        button.frame = frame;
        
    }
    
    //头部添加滚动视图
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = self.bannerViewArray.count - 1;
    button.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.frame.size.height - BarViewHeight);
    [button addTarget:self action:@selector(bannerTouch:) forControlEvents:UIControlEventTouchUpInside];
    NSString *imageLink = [self.delegate bannerLinks:self linkForIndexOfBanner:self.bannerViewArray.count - 1];
    
    [button setBackgroundImage:[UIImage imageNamed:imageLink] forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeCenter;
    
    [banerScrollerView addSubview:button];
    
    //尾部添加头部视图
    UIButton *lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    lastButton.tag = 0;
    lastButton.frame = CGRectMake((bannerNum+1) * SCREEN_WIDTH, 0, SCREEN_WIDTH, self.frame.size.height - BarViewHeight);
    [lastButton addTarget:self action:@selector(bannerTouch:) forControlEvents:UIControlEventTouchUpInside];
    NSString *lastButtonImageLink = [self.delegate bannerLinks:self linkForIndexOfBanner:0];
    
    [lastButton setBackgroundImage:[UIImage imageNamed:imageLink] forState:UIControlStateNormal];

    lastButton.contentMode = UIViewContentModeCenter;
    
    [banerScrollerView addSubview:lastButton];
    
    //创建广告下面的标志图
    CGFloat bar_x = 0;
    CGFloat bar_y = img_h;
    CGFloat bar_w = self.frame.size.width/bannerNum;
    CGFloat bar_h = BarViewHeight;
    
    for (int i=0; i<bannerNum; i++) {
        
        UIView *barView = [[UIView alloc]init];
        barView.frame = CGRectMake(bar_x, bar_y, bar_w, bar_h);

        barView.tag = i;
        [self addSubview:barView];
        [self.bottomViewArray addObject:barView];
        
        bar_x += bar_w;
    }
    
    //添加滑块游标
    UIView *actionView = [[UIView alloc]init];
    if (self.bottomViewArray.count) {
        UIView *firstBarView = self.bottomViewArray[0];
        actionView.frame = firstBarView.frame;
        actionView.backgroundColor = _barViewColor ? _barViewColor : barViewColor;
        self.actionBarView = actionView;
        [self addSubview:_actionBarView];
    }
    
    //将scrollView移动到第一个位置
    [banerScrollerView setContentOffset:CGPointMake(self.bannerScrollView.frame.size.width, 0)];
    
    
}

#pragma -mark- 对外接口
- (void)startLoopScroll{

    [self startSchedulTime];
}

#pragma -mark- 事件处理
- (void)bannerTouch:(UIButton*)button{

    [self.delegate bannerView:self didClicked:button.tag];
    
}

- (void)endSchedulTime{
    // 停止计时
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)startSchedulTime{
    // 开始计时
//    [self.timer setFireDate:[NSDate distantPast]];
    [self.timer setFireDate:[NSDate dateWithTimeInterval:1.5 sinceDate:[NSDate date]]];

}

// 释放时取消定时器
- (void)dealloc {
    [self.timer invalidate];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [self creatView];
}

- (void)scrollBanner:(NSTimer *)timer{
    
    if (self.isDraging) {
        return;
    }

    
    CGFloat offset_x = 0;
    CGFloat offset_y = 0;
    
    
    if (_index == 0) {
        
        offset_x = _index * self.frame.size.width;
        
        [UIView animateWithDuration:ScrollTime animations:^{
            [self.bannerScrollView setContentOffset:CGPointMake(offset_x, offset_y) animated:NO];
            
        } completion:^(BOOL finished) {
            
            [self.bannerScrollView setContentOffset:CGPointMake(self.bannerViewArray.count * SCREEN_WIDTH, offset_y) animated:NO];

        }];
        
    }else if(_index == self.bannerViewArray.count + 1){
        
        
        offset_x = _index * self.frame.size.width;
        
        [UIView animateWithDuration:ScrollTime animations:^{

            //处理最后一张滚动的时候底部滑块的位置动画
            self.isChangeActionBarFrame = NO;
            
            //最后的动画
            [self.bannerScrollView setContentOffset:CGPointMake(offset_x, offset_y) animated:NO];
            UIView *lastView = [[self bottomViewArray] lastObject];
            CGRect frame = lastView.frame;
            frame.origin.x = frame.origin.x + frame.size.width;
            self.actionBarView.frame = frame;
            
            
            self.isChangeActionBarFrame = YES;
            
        } completion:^(BOOL finished) {
            
            [self.bannerScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, offset_y) animated:NO];
        }];
        
        
    }else{
    
        offset_x = _index * self.frame.size.width;
        [UIView animateWithDuration:ScrollTime delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self.bannerScrollView setContentOffset:CGPointMake(offset_x, offset_y) animated:NO];
        } completion:nil];

    }
    

    _index ++;

}

- (void)scrollBarView{

    if(!self.bottomViewArray.count){
    
        return;
    }
    
    UIView *view = self.bottomViewArray[_index];
    
    [UIView animateWithDuration:ScrollTime delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.actionBarView.transform = CGAffineTransformMakeTranslation(view.frame.origin.x,0);
    } completion:nil];
}


#pragma -mark- ScrollView的代理方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat offset_x = scrollView.contentOffset.x;
    self.index = offset_x/scrollView.frame.size.width;
    
    if (!self.isChangeActionBarFrame) {
        return;
    }
    
    //实时改变底部滑块的位置
    CGFloat offsetX_zoom = (offset_x - SCREEN_WIDTH * self.index) / SCREEN_WIDTH;
    UIView *currentView = nil;
    
    if (self.index == 0) {
        //第一个轮播图的时候,从第一个滑动到最后一个位置的时候底部滑动条变换（由长变短）
        currentView = [self.bottomViewArray lastObject];
        CGRect frame = currentView.frame;
        
        self.actionBarView.frame = CGRectMake(0, frame.origin.y, offsetX_zoom * (SCREEN_WIDTH/self.bottomViewArray.count), frame.size.height);
        return;
        
    }else if (self.index == (self.bannerViewArray.count + 1)){
        //最后一个轮播图的时候
        currentView = [self.bottomViewArray firstObject];
        
    }else{
    
        currentView = self.bottomViewArray[self.index - 1];
    }
    
    CGRect frame = currentView.frame;
    frame.origin.x += offsetX_zoom * (SCREEN_WIDTH/self.bottomViewArray.count);
    self.actionBarView.frame = frame;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{

    self.isDraging = YES;
    [self endSchedulTime];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    self.isDraging = NO;
    [self startSchedulTime];
    
    // 如果当前页是第0页就跳转到数组中最后一个地方进行跳转
    if (self.index == 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * ([[self bannerViewArray] count]), 0) animated:NO];
    }else if (self.index == [self bannerViewArray].count + 1){
        // 如果是第最后一页就跳转到数组第一个元素的地点
        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width, 0) animated:NO];
    }


    
    [self startSchedulTime];
}

#pragma -mark- 广告图设计
- (void)reloadBannerScrollerView {
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    self.bannerViewArray = nil;
    self.bottomViewArray = nil;
    
    [self creatView];
}



#pragma -mark- 懒加载
- (NSMutableArray *)bannerViewArray{

    if (_bannerViewArray == nil) {
        _bannerViewArray = [[NSMutableArray alloc]init];
    }
    
    return _bannerViewArray;
}

- (NSMutableArray *)bottomViewArray{

    if (_bottomViewArray == nil) {
        _bottomViewArray = [[NSMutableArray alloc]init];
    }
    
    return _bottomViewArray;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:AnimotionTime target:self selector:@selector(scrollBanner:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    
    return _timer;
}

@end
