//
//  SkyperLoadingView.h
//  AnimationDemo
//
//  Created by Che Yongzi on 2017/3/23.
//  Copyright © 2017年 Che Yongzi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SkyperLoadingView : UIView

//动画执行时间,默认为1.8s
@property (assign, nonatomic) CGFloat       animationDuration;

//每个○动画开始执行之间的间隔,默认为0.1
@property (assign, nonatomic) CGFloat       animationStartOffset;

//原点背景颜色,默认为240,96,0
@property (strong, nonatomic) UIColor       *dotBackColor;

//动画可执行的○个数,默认5个
@property (assign, nonatomic) NSInteger     dotCount;

//动画执行的○的宽带，默认为4 PX
@property (assign, nonatomic) CGFloat       dotWidth;

//动画执行的○的缩放比例，默认为0.4
@property (assign, nonatomic) CGFloat       dotScale;

//动画是否自动执行,默认自动执行动画NO
@property (assign, nonatomic) BOOL          autoAnimation;

/**
 动画手动启动

 @param delayTime 动画延时启动的时间
 */
- (void)startAnimation:(CGFloat)delayTime;

/**
 动画手动关闭
 
 @param delayTime 动画延时关闭的时间
 */
- (void)stopAnimation:(CGFloat)delayTime;

@end
