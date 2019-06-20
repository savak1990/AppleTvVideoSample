//
//  PlayerView.h
//  VideoExample
//
//  Created by C: Vyacheslav Klyovan on 6/20/19.
//  Copyright © 2019 C: Vyacheslav Klyovan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerView : UIView
@property (nonatomic) AVPlayer *player;
@end

NS_ASSUME_NONNULL_END
