//
//  PlayVideoViewController.h
//  VideoExample
//
//  Created by C: Vyacheslav Klyovan on 6/20/19.
//  Copyright © 2019 C: Vyacheslav Klyovan. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayVideoViewController : UIViewController
@property (nonatomic) AVPlayer *player;
@end

NS_ASSUME_NONNULL_END
