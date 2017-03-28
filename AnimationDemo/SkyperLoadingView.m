//
//  SkyperLoadingView.m
//  AnimationDemo
//
//  Created by Che Yongzi on 2017/3/23.
//  Copyright © 2017年 Che Yongzi. All rights reserved.
//

#import "SkyperLoadingView.h"

@interface SkyperLoadingView ()

//用于存储动画的圆圈
@property (strong, nonatomic) NSMutableArray    *dotLayerArray;
@property (strong, nonatomic) NSMutableArray    *dotViewArray;
//用于延时启动动画
@property (strong, nonatomic) NSTimer           *startDelayTimer;
@property (strong, nonatomic) NSTimer           *stopDelayTimer;

@end

@implementation SkyperLoadingView

#pragma mark - Init
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initDefatulProperty];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initDefatulProperty];
    }
    return self;
}

- (void)initDefatulProperty {
    self.backgroundColor = [UIColor clearColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    _autoAnimation = NO;
    _dotCount = 5;
    _dotWidth = 4;
    _animationDuration = 1.8;
    _animationStartOffset = 0.1;
    _dotScale = 0.4;
    _dotBackColor = [UIColor colorWithRed:240.f/255 green:96.f/255 blue:0 alpha:1.0];
    
    _dotLayerArray = [NSMutableArray array];
    _dotViewArray = [NSMutableArray array];
}

#pragma mark - view method
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview != nil) {
        [self initDotInterface];
        if (self.autoAnimation) {
            [self startAnimation:0];
        }
    }
}

#pragma mark - Start Stop Animation method
- (void)startAnimation:(CGFloat)delayTime {
    if (_startDelayTimer) {
        [_startDelayTimer invalidate];
        _startDelayTimer = nil;
    }
    __weak typeof(self) weakSelf = self;
    _startDelayTimer = [NSTimer scheduledTimerWithTimeInterval:delayTime repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf startAction];
    }];
}

- (void)stopAnimation:(CGFloat)delayTime {
    if (_stopDelayTimer) {
        [_stopDelayTimer invalidate];
        _stopDelayTimer = nil;
    }
    __weak typeof(self) weakSelf = self;
    _stopDelayTimer = [NSTimer scheduledTimerWithTimeInterval:delayTime repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf stopAction];
    }];
}

#pragma mark - Init Dot Interface
- (void)initDotInterface {
    for (int index = 0; index < _dotCount; index++) {
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _dotWidth, _dotWidth)];
        [_dotViewArray addObject:dotView];
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = [UIBezierPath bezierPathWithRoundedRect:dotView.bounds cornerRadius:_dotWidth/2].CGPath;
        layer.fillColor = _dotBackColor.CGColor;
        [_dotLayerArray addObject:layer];
        [dotView.layer addSublayer:layer];
        
        CGFloat yAnchor = (self.bounds.size.height/2 - _dotWidth/2)/_dotWidth;
        
        dotView.layer.anchorPoint = CGPointMake(0.5, yAnchor);
        dotView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        
        [self addSubview:dotView];
    }
}

#pragma mark - Start Stop Action
- (void)startAction {
    if (_dotViewArray.count == 0 || _dotLayerArray.count == 0) {
        [self initDotInterface];
    }
    for (int index = 0; index < _dotCount; index++) {
        UIView *dotView = _dotViewArray[index];
        [dotView.layer addAnimation:[self createDotViewAnimation:index] forKey:@"DotViewRotateAnimation"];
        
        CAShapeLayer *layer = _dotLayerArray[index];
        [layer addAnimation:[self createDotLayerAnimation:index] forKey:@"DotLayerScaleAnimation"];
    }
}

- (CAAnimationGroup*)createDotViewAnimation:(int)index {
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation1.duration = _animationDuration/2;
    animation1.toValue = @(M_PI);
    animation1.removedOnCompletion = NO;
    animation1.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation2.duration = _animationDuration/2;
    animation2.fromValue = @(-M_PI);
    animation2.toValue = @(0);
    animation2.removedOnCompletion = NO;
    animation2.fillMode = kCAFillModeForwards;
    animation2.beginTime = _animationDuration/2;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = _animationDuration;
    group.removedOnCompletion = YES;
    group.fillMode = kCAFillModeForwards;
    group.animations = @[animation1, animation2];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.repeatCount = CGFLOAT_MAX;
    group.beginTime = (index+1)*_animationStartOffset;
    
    return group;
}

- (CAAnimationGroup*)createDotLayerAnimation:(int)index {
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation1.duration = _animationDuration/2;
    animation1.toValue = @(0.4);
    animation1.removedOnCompletion = NO;
    animation1.autoreverses = YES;
    animation1.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = _animationDuration;
    group.removedOnCompletion = YES;
    group.fillMode = kCAFillModeForwards;
    group.animations = @[animation1];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.repeatCount = CGFLOAT_MAX;
    group.beginTime = (index+1)*_animationStartOffset;
    
    return group;
}

- (void)stopAction {
    for (UIView *dotView in _dotViewArray) {
        [dotView.layer removeAllAnimations];
    }
    
    for (CAShapeLayer *layer in _dotLayerArray) {
        [layer removeAllAnimations];
    }
}

#pragma mark - becomeActive
- (void)becomeActive {
    [self startAction];
}

#pragma mark - Dealloc
- (void)dealloc {
    [self removeFromSuperview];
}

@end
