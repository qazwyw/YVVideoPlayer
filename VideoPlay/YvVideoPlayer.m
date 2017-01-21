//
//  YvVideoPlayer.m
//  VideoPlay
//
//  Created by 1 on 2017/1/18.
//  Copyright © 2017年 Yvan. All rights reserved.
//

#import "YvVideoPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "YvControlBar.h"

//播放状态keypath
static NSString * const kStatusKeyPath = @"status";
//缓冲keypath
static NSString * const kTimeRangeKeyPath = @"loadedTimeRanges";


@interface YvVideoPlayer()<YvControlBarDelegate>
//控制条
@property(nonatomic, strong)YvControlBar *controlBar;
//加载指示器
@property(nonatomic, strong)UIActivityIndicatorView *activityIndiView;

@property(nonatomic, strong)AVPlayer *player;

@property(nonatomic, strong)AVPlayerLayer *playerLayer;

@property(nonatomic, assign)CGRect smallScreenFrame;

@property(nonatomic, assign)CGRect fullScreenFrame;

@property(nonatomic, copy)NSString *currentVideoUrlString;
@end

@implementation YvVideoPlayer
+(instancetype)playerWithFrame:(CGRect)frame{
    YvVideoPlayer *videoPlayer = [[YvVideoPlayer alloc]initWithFrame:frame];
    return videoPlayer;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap)]];
    }
    return self;
}

//点击屏幕
-(void)tap{
    self.controlBar.hidden = !self.controlBar.hidden;
}

-(void)initUI{
    self.smallScreenFrame = self.frame;
    self.fullScreenFrame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
    
    CGRect controlBarFrame = self.bounds;
    controlBarFrame.origin.y = CGRectGetHeight(controlBarFrame) - kControlBarHeight;
    controlBarFrame.size.height = kControlBarHeight;
    self.controlBar = [[YvControlBar alloc]initWithFrame:controlBarFrame];
    self.controlBar.delegate = self;
    [self addSubview:self.controlBar];
    
    
    
    self.activityIndiView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndiView setHidesWhenStopped:YES];
    [self.activityIndiView stopAnimating];
    [self addSubview:self.activityIndiView];
}

-(AVPlayer *)player{
    if (!_player) {
        _player = [[AVPlayer alloc]init];
        [self addProgressObserver];
    }
    return _player;
}

#pragma mark 播放/暂停点击
-(void)controlBar:(YvControlBar *)controlBar didClickPlayBtn:(UIButton *)playBtn{
    //播放结束后再次点击播放
    if (self.controlBar.progressView.progress >= 1.0 && playBtn.selected == NO) {
        [self.player seekToTime:CMTimeMake(0, 1.0) completionHandler:^(BOOL finished) {
            [self.player play];
            [playBtn setSelected:YES];
        }];
        return;
    }
    if (self.player.rate == 0) {
        [self.player play];
        [playBtn setSelected:YES];
    }else{
        [self.player pause];
        [playBtn setSelected:NO];
    }
}

#pragma mark 全屏切换
-(void)controlBar:(YvControlBar *)controlBar didClickFullScreenBtn:(UIButton *)screenBtn{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    self.transform = CGAffineTransformIdentity;
    
    if (screenBtn.selected) {//退出全屏
        self.frame = self.smallScreenFrame;
        self.transform = CGAffineTransformMakeRotation(0);    
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    }else{//全屏
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.frame = self.fullScreenFrame;
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
    }
    self.playerLayer.frame = self.bounds;
    CGRect controlBarFrame = self.bounds;
    controlBarFrame.origin.y = CGRectGetHeight(controlBarFrame) - kControlBarHeight;
    controlBarFrame.size.height = kControlBarHeight;
    self.controlBar.frame = controlBarFrame;
    [UIView commitAnimations];
    
    screenBtn.selected = !screenBtn.selected;
}

#pragma mark - 滑块操作
#pragma mark 滑块开始
-(void)controlBar:(YvControlBar *)controlBar sliderStartChangeValue:(UISlider *)slider{
    [self.player setRate:0];
}

-(void)controlBar:(YvControlBar *)controlBar sliderValueChanged:(UISlider *)slider{
    CGFloat totalTimeSecs = CMTimeGetSeconds(self.player.currentItem.duration);
    CGFloat currentTimeSecs = totalTimeSecs * slider.value;
    controlBar.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[self getTimeStringWithSecs:currentTimeSecs],[self getTimeStringWithSecs:totalTimeSecs]];
}

#pragma mark 滑块松手
-(void)controlBar:(YvControlBar *)controlBar sliderDidChangedValue:(UISlider *)slider{
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
        [strongSelf.controlBar.slider setValue:finalValue animated:YES];
        strongSelf.controlBar.timeLabel.text = [NSString stringWithFormat:@"%@/%@",[strongSelf getTimeStringWithSecs:currentTimeSecs],[strongSelf getTimeStringWithSecs:totalTimeSecs]];
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
-(void)playend:(NSNotification *)notification{
    [self.controlBar.playBtn setSelected:NO];
}


#pragma mark - KVO监听正在播放的视频
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:kStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:kTimeRangeKeyPath options:NSKeyValueObservingOptionNew context:nil];
    //播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playend:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
#pragma mark 移除
-(void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    [playerItem removeObserver:self forKeyPath:kStatusKeyPath];
    [playerItem removeObserver:self forKeyPath:kTimeRangeKeyPath];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        
        [self.controlBar.progressView setProgress:totalBuffer/totalTime animated:YES];
    }
}


#pragma mark 在线播放
-(void)playWithVideoUrlString:(NSString *)videoUrlString{
    if (!videoUrlString) {
        return;
    }
    self.currentVideoUrlString = videoUrlString;
    NSURL *url = [NSURL URLWithString:videoUrlString];
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    [self addObserverToPlayerItem:self.player.currentItem];
    [self controlBar:self.controlBar didClickPlayBtn:self.controlBar.playBtn];
}


@end
