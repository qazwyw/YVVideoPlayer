//
//  YvControlBar.h
//  VideoPlay
//
//  Created by 1 on 2017/1/21.
//  Copyright © 2017年 Yvan. All rights reserved.
//

#import <UIKit/UIKit.h>

//控件之间的距离
static int const kSubviewsPanding = 10;
//底部控制条高度
static int const kControlBarHeight = 50;
//按钮宽度
static int const kBtnWidth = 50;
//时间label宽度
static int const kTimeLabelWidth = 80;
//已播放的路径颜色
#define kPlayedColor [UIColor redColor]
//缓冲的路径颜色
#define kTimeRangesColor [UIColor whiteColor]
//进度条底色
#define kTrackColor [UIColor grayColor]

@protocol YvControlBarDelegate;
@interface YvControlBar : UIView
//播放按钮
@property(nonatomic, strong)UIButton *playBtn;
//全屏按钮
@property(nonatomic, strong)UIButton *fullScreenBtn;
//缓冲进度条
@property(nonatomic, strong)UIProgressView *progressView;
//播放进度（滑块）
@property(nonatomic, strong)UISlider *slider;
//时间显示
@property(nonatomic, strong)UILabel *timeLabel;
@property(nonatomic, weak)id<YvControlBarDelegate> delegate;
@end

@protocol YvControlBarDelegate <NSObject>
//播放点击
- (void)controlBar:(YvControlBar *)controlBar didClickPlayBtn:(UIButton *)playBtn;
//全屏点击
- (void)controlBar:(YvControlBar *)controlBar didClickFullScreenBtn:(UIButton *)screenBtn;
//滑竿按下
- (void)controlBar:(YvControlBar *)controlBar sliderStartChangeValue:(UISlider *)slider;
//滑竿拖动
- (void)controlBar:(YvControlBar *)controlBar sliderValueChanged:(UISlider *)slider;
//滑竿松手
- (void)controlBar:(YvControlBar *)controlBar sliderDidChangedValue:(UISlider *)slider;
@end
