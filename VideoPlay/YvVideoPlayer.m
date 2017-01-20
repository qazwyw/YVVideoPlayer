//
//  YvVideoPlayer.m
//  VideoPlay
//
//  Created by 1 on 2017/1/18.
//  Copyright © 2017年 Yvan. All rights reserved.
//

#import "YvVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#define kControlBarHeight 50
#define kTimeLabelWidth 80
//播放状态keypath
static NSString * const kStatusKeyPath = @"status";
//缓冲keypath
static NSString * const kTimeRangeKeyPath = @"loadedTimeRanges";
//已播放的路径颜色
#define kPlayedColor [UIColor redColor]
//缓冲的路径颜色
#define kTimeRangesColor [UIColor whiteColor]
//进度条底色
#define kTrackColor [UIColor grayColor]

@interface YvVideoPlayer()
//控制条
@property(nonatomic, strong)UIView *controlBar;
//播放按钮
@property(nonatomic, strong)UIButton *playBtn;
//缓冲进度条
@property(nonatomic, strong)UIProgressView *progressView;
//播放进度（滑块）
@property(nonatomic, strong)UISlider *slider;
//时间显示
@property(nonatomic, strong)UILabel *timeLabel;
//加载指示器
@property(nonatomic, strong)UIActivityIndicatorView *activityIndiView;

@property(nonatomic, strong)AVPlayer *player;

@end

@implementation YvVideoPlayer

+(instancetype)playerWithContainerView:(UIView *)containerView{
    YvVideoPlayer *videoPlayer = [[YvVideoPlayer alloc]initWithContainerView:containerView];
    return videoPlayer;
}

-(instancetype)initWithContainerView : (UIView *)containerView{
    if (self = [super init]) {
        [self initUIWithContainerView:containerView];
    }
    return self;
}

-(void)initUIWithContainerView : (UIView *)containerView{
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    playerLayer.frame = containerView.bounds;
    [containerView.layer addSublayer:playerLayer];
    
    CGRect controlBarFrame = containerView.bounds;
    controlBarFrame.origin.y = CGRectGetHeight(controlBarFrame) - kControlBarHeight;
    controlBarFrame.size.height = kControlBarHeight;
    self.controlBar = [[UIView alloc]initWithFrame:controlBarFrame];
    [containerView addSubview:self.controlBar];
    
    UIView *transparentView = [[UIView alloc]initWithFrame:self.controlBar.bounds];
    transparentView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.controlBar addSubview:transparentView];
    
    self.playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, kControlBarHeight)];
    [self.playBtn setBackgroundColor:[UIColor purpleColor]];
    [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [self.playBtn setTitle:@"暂停" forState:UIControlStateSelected];
    [self.playBtn setTitle:@"暂停" forState:UIControlStateSelected |
     UIControlStateHighlighted];
    [self.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBar addSubview:self.playBtn];
    
    self.progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.playBtn.frame) + 10, 0, CGRectGetWidth(containerView.frame) - CGRectGetMaxX(self.playBtn.frame) - 20 - kTimeLabelWidth, kControlBarHeight)];
    //缓冲颜色
    self.progressView.tintColor = kTimeRangesColor;
    //底色
    self.progressView.trackTintColor = kTrackColor;
    self.progressView.center = CGPointMake(self.progressView.center.x, kControlBarHeight/2);
    [self.controlBar addSubview:self.progressView];
    
    CGRect progressViewFrame = self.progressView.frame;
    progressViewFrame.origin.x -= 2;
    progressViewFrame.size.width += 5;
    progressViewFrame.size.height = kControlBarHeight;
    self.slider = [[UISlider alloc]initWithFrame:progressViewFrame];
    self.slider.center = self.progressView.center;
    self.slider.minimumTrackTintColor = kPlayedColor;
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged ];
    [self.slider addTarget:self action:@selector(sliderStartChangeValue:) forControlEvents: UIControlEventTouchDown];
    [self.slider addTarget:self action:@selector(sliderDidChangedValue:) forControlEvents: UIControlEventTouchCancel | UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.controlBar addSubview:self.slider];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.progressView.frame), 0, kTimeLabelWidth, kControlBarHeight)];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.font = [UIFont systemFontOfSize:10];
    self.timeLabel.textColor = [UIColor whiteColor];
    [self.controlBar addSubview:self.timeLabel];
    
    self.activityIndiView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndiView setHidesWhenStopped:YES];
    [self.activityIndiView stopAnimating];
    [containerView addSubview:self.activityIndiView];
}

-(AVPlayer *)player{
    if (!_player) {
        _player = [[AVPlayer alloc]init];
        [self addProgressObserver];
    }
    return _player;
}

#pragma mark 播放/暂停点击
-(void)playBtnClick : (UIButton *)sender{
    if (self.player.rate == 0) {
        [self.player play];
        [sender setSelected:YES];
    }else{
        [self.player pause];
        [sender setSelected:NO];
    }
}

#pragma mark - 滑块操作
#pragma mark 滑块开始
-(void)sliderStartChangeValue : (UISlider *)slider{
    
    NSLog(@"sliderStartChangeValue");
    [self.player setRate:0];
}

-(void)sliderValueChanged : (UISlider *)slider{
    NSLog(@"sliderValueChanged");
    CGFloat totalTimeSecs = CMTimeGetSeconds(self.player.currentItem.duration);
    CGFloat currentTimeSecs = totalTimeSecs * slider.value;
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self getTimeStringWithSecs:currentTimeSecs],[self getTimeStringWithSecs:totalTimeSecs]];
}


#pragma mark 滑块松手
-(void)sliderDidChangedValue : (UISlider *)slider{
    NSLog(@"sliderDidChangedValue");
    [self.player setRate:1];
    CGFloat totalTimeSecs = CMTimeGetSeconds(self.player.currentItem.duration);
    CGFloat currentTimeSecs =  slider.value * totalTimeSecs;
    CMTime time = CMTimeMake(currentTimeSecs, 1);
    [self.player seekToTime:time];
}

#pragma mark 添加进度观察
-(void)addProgressObserver{
    __weak typeof(self) weakself = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(weakself) strongSelf = weakself;
        CGFloat currentTimeSecs = CMTimeGetSeconds(time);
        CGFloat totalTimeSecs = CMTimeGetSeconds(strongSelf.player.currentItem.duration);
        CGFloat finalValue = currentTimeSecs/totalTimeSecs;
        NSLog(@"currentTimeSecs = %f，totalTimeSecs = %f，finalValue = %f",
              currentTimeSecs,totalTimeSecs,finalValue);
        [strongSelf.slider setValue:finalValue animated:YES];
        strongSelf.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[strongSelf getTimeStringWithSecs:currentTimeSecs],[strongSelf getTimeStringWithSecs:totalTimeSecs]];
    }];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(NSString *)getTimeStringWithSecs : (int)timeSecs{
    int min = timeSecs / 60;
    int sec = (int) timeSecs % 60;
    return [NSString stringWithFormat:@"%02d:%02d",min,sec];
}


#pragma mark 播放结束
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
}


#pragma mark - KVO监听正在播放的视频
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:kStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:kTimeRangeKeyPath options:NSKeyValueObservingOptionNew context:nil];
}
#pragma mark 移除
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:kStatusKeyPath];
    [playerItem removeObserver:self forKeyPath:kTimeRangeKeyPath];
}

#pragma mark KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:kStatusKeyPath]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
        }
    }else if([keyPath isEqualToString:kTimeRangeKeyPath]){
        NSArray *array=playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        CGFloat startSeconds = CMTimeGetSeconds(timeRange.start);
        CGFloat durationSeconds = CMTimeGetSeconds(timeRange.duration);
        CGFloat totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        
        CGFloat totalTime = CMTimeGetSeconds(playerItem.duration);
        NSLog(@"共缓冲：%.2f",totalBuffer);
        CGFloat currentTimeSecs = CMTimeGetSeconds(self.player.currentItem.currentTime);
        //缓冲的没有当前正在播放的多，就显示卡顿菊花
        if (totalBuffer < currentTimeSecs) {
            NSLog(@"缓冲的没有当前正在播放的多，就显示卡顿菊花");
            self.activityIndiView.hidden = NO;
            [self.activityIndiView startAnimating];
        }else{
            [self.activityIndiView stopAnimating];
        }
        
        [self.progressView setProgress:totalBuffer/totalTime animated:YES];
    }
}


#pragma mark 在线播放
-(void)playWithVideoUrlString:(NSString *)videoUrlString{
    NSURL *url = [NSURL URLWithString:videoUrlString];
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    [self addObserverToPlayerItem:self.player.currentItem];
    [self playBtnClick:self.playBtn];
}
@end
