//
//  PlayVideoViewController.m
//  VideoExample
//
//  Created by C: Vyacheslav Klyovan on 6/20/19.
//  Copyright © 2019 C: Vyacheslav Klyovan. All rights reserved.
//

#import "PlayVideoViewController.h"
#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayVideoViewController ()

@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;

@end

@implementation PlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"PlayVideoViewController.viewDidLoad: videoUrl=%@", _videoUrlStr);
    
    PlayerView *playerView = (PlayerView *)[self view];
    
    NSURL *nsVideoUrl = [NSURL URLWithString:_videoUrlStr];
    _player = [AVPlayer playerWithURL: nsVideoUrl];
    playerView.player = _player;
    
    [_player play];
}

@end
