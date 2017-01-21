//
//  YvVideoPlayer.h
//  VideoPlay
//
//  Created by 1 on 2017/1/18.
//  Copyright © 2017年 Yvan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YvVideoPlayer : UIView

+(instancetype)playerWithFrame:(CGRect)frame;

//在线播放
-(void)playWithVideoUrlString : (NSString *)videoUrlString;

@end
