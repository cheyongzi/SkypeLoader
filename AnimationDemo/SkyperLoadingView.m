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
    _animationDuration = 1.4;
    _animationStartOffset = 0.08;
    _dotScale = 0.5;
    _dotBackColor = [UIColor colorWithRed:240.f/255 green:96.f/255 blue:0 alpha:1.0];
    
    _dotLayerArray = [NSMutableArray array];
}

#pragma mark - view method
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self initDotInterface];
    if (self.autoAnimation) {
        [self startAnimation:0];
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
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = CGRectMake(0, 0, _dotWidth, _dotWidth);
        layer.position = CGPointMake(self.bounds.size.width/2, _dotWidth/2);
        layer.backgroundColor = _dotBackColor.CGColor;
        layer.cornerRadius = _dotWidth/2;
        [_dotLayerArray addObject:layer];
        
        [self.layer addSublayer:layer];
    }
}

#pragma mark - Start Stop Action
- (void)startAction {
    for (int index = 0; index < _dotCount; index++) {
        CAShapeLayer *layer = _dotLayerArray[index];
        [layer addAnimation:[self createAnimation:index] forKey:@"DotLayerAnimation"];
    }
}

- (CAAnimationGroup*)createAnimation:(int)index {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.width/2) radius:self.bounds.size.width/2-_dotWidth/2 startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
    
    CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animation];
    animation1.keyPath = @"position";
    animation1.path = path.CGPath;
    animation1.rotationMode = kCAAnimationRotateAuto;
    
    CABasicAnimation *animation2 = [CABasicAnimation animation];
    animation2.keyPath = @"transform.scale";
    animation2.toValue = @(_dotScale);
    animation2.duration = _animationDuration/2;
    animation2.autoreverses = YES;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = _animationDuration;
    group.removedOnCompletion = YES;
    group.fillMode = kCAFillModeForwards;
    group.animations = @[animation1,animation2];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.repeatCount = INFINITY;
    group.beginTime = (index+1)*_animationStartOffset;
    
    return group;
}

- (void)stopAction {
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
