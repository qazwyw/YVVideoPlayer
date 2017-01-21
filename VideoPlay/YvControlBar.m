//
//  YvControlBar.m
//  VideoPlay
//
//  Created by 1 on 2017/1/21.
//  Copyright © 2017年 Yvan. All rights reserved.
//


#import "YvControlBar.h"
@interface YvControlBar()
@property(nonatomic, strong)UIView *transparentView;
@end

@implementation YvControlBar

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.transparentView = [[UIView alloc]initWithFrame:self.bounds];
        self.transparentView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.7];
        [self addSubview:self.transparentView];
        
        self.playBtn = [[UIButton alloc] init];
        [self.playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
        [self.playBtn setTitle:@"暂停" forState:UIControlStateSelected];
        [self.playBtn setTitle:@"暂停" forState:UIControlStateSelected |
         UIControlStateHighlighted];
        [self.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playBtn];
        
        self.fullScreenBtn = [[UIButton alloc] init];
        [self.fullScreenBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.fullScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
        [self.fullScreenBtn setTitle:@"退全" forState:UIControlStateSelected];
        [self.fullScreenBtn setTitle:@"退全" forState:UIControlStateSelected |
         UIControlStateHighlighted];
        [self.fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.fullScreenBtn];
        
        self.progressView = [[UIProgressView alloc]init];
        //缓冲颜色
        self.progressView.tintColor = kTimeRangesColor;
        //底色
        self.progressView.trackTintColor = kTrackColor;
       
        [self addSubview:self.progressView];
        
        
        self.slider = [[UISlider alloc]init];
        self.slider.minimumTrackTintColor = kPlayedColor;
        self.slider.maximumTrackTintColor = [UIColor clearColor];
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged ];
        [self.slider addTarget:self action:@selector(sliderStartChangeValue:) forControlEvents: UIControlEventTouchDown];
        [self.slider addTarget:self action:@selector(sliderDidChangedValue:) forControlEvents: UIControlEventTouchCancel | UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self addSubview:self.slider];
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.font = [UIFont systemFontOfSize:10];
        self.timeLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.timeLabel];
        self.frame = frame;
    }
    return self;
}


-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.transparentView.frame = self.bounds;
    self.playBtn.frame = CGRectMake(0, 0, kBtnWidth, kControlBarHeight);
    self.fullScreenBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - kBtnWidth, 0, kBtnWidth, kControlBarHeight);
    
    self.progressView.frame = CGRectMake(CGRectGetMaxX(self.playBtn.frame) + kSubviewsPanding, 0, CGRectGetMinX(self.fullScreenBtn.frame) - CGRectGetMaxX(self.playBtn.frame) - 2 * kSubviewsPanding - kTimeLabelWidth, kControlBarHeight);
     self.progressView.center = CGPointMake(self.progressView.center.x, kControlBarHeight/2);
    
    CGRect progressViewFrame = self.progressView.frame;
    //UISlider跟UIProgressView相同宽度两端对不齐进行微调
    progressViewFrame.origin.x -= 2;
    progressViewFrame.size.width += 5;
    progressViewFrame.size.height = kControlBarHeight;
    self.slider.frame = progressViewFrame;
    self.slider.center = self.progressView.center;
    self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.progressView.frame), 0, kTimeLabelWidth, kControlBarHeight);
}


#pragma mark 播放/暂停点击
-(void)playBtnClick : (UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(controlBar:didClickPlayBtn:)]) {
        [self.delegate controlBar:self didClickPlayBtn:sender];
    }
}

#pragma mark 全屏切换
-(void)fullScreenBtnClick : (UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(controlBar:didClickFullScreenBtn:)]) {
        [self.delegate controlBar:self didClickFullScreenBtn:sender];
    }
}

#pragma mark - 滑块操作
#pragma mark 滑块开始
-(void)sliderStartChangeValue : (UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(controlBar:sliderStartChangeValue:)]) {
        [self.delegate controlBar:self sliderStartChangeValue:slider];
    }
}

#pragma mark 滑块拖动
-(void)sliderValueChanged : (UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(controlBar:sliderValueChanged:)]) {
        [self.delegate controlBar:self sliderValueChanged:slider];
    }
}


#pragma mark 滑块松手
-(void)sliderDidChangedValue : (UISlider *)slider{
    if ([self.delegate respondsToSelector:@selector(controlBar:sliderDidChangedValue:)]) {
        [self.delegate controlBar:self sliderDidChangedValue:slider];
    }
}

-(void)setHidden:(BOOL)hidden{
//    __block CGRect frame = self.frame;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = hidden ? 0 : 1;
//        frame.origin.y = hidden?CGRectGetMinY(frame)+CGRectGetHeight(frame):CGRectGetMinY(frame)-CGRectGetHeight(frame);
//        self.frame = frame;
    } completion:^(BOOL finished) {
        [super setHidden:hidden];
    }];}
@end
