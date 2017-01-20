//
//  YvVideoPlayer.h
//  VideoPlay
//
//  Created by 1 on 2017/1/18.
//  Copyright © 2017年 Yvan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YvVideoPlayer : UIView

+(instancetype)playerWithContainerView : (UIView *)containerView;

-(instancetype)initWithContainerView : (UIView *)containerView;
//在线播放
-(void)playWithVideoUrlString : (NSString *)videoUrlString;

-(void)playBtnClick : (UIButton *)sender;
@end
