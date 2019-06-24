//
//  ViewController.m
//  VideoExample
//
//  Created by C: Vyacheslav Klyovan on 6/18/19.
//  Copyright © 2019 C: Vyacheslav Klyovan. All rights reserved.
//

#import "ViewController.h"
#import "PlayVideoViewController.h"
#import "ButtonTagEnum.h"
#import <AVKit/AVKit.h>

#define BASE_IP @"http://192.168.211.157"

NSString *const UrlNokiaSampleAsset = @"https://s3.amazonaws.com/hls-demos/nokia/index.m3u8";
NSString *const UrlLocalTestAsset = BASE_IP@":8000/index.m3u8";

NSString *const SegueNokiaSampleAsset = @"nokiaAssetTransition";
NSString *const SegueLocalTestAsset = @"localAssetTransition";

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)onPlayVideoWithController:(UIButton *) sender {
    NSLog(@"onPlayVideoWithController: %lu", [ sender tag ]);
    
    NSString *videoUrlStr = UrlNokiaSampleAsset;
    switch ([sender tag]) {
        case ButtonNokiaAssetController:
            videoUrlStr = UrlNokiaSampleAsset;
            break;
        case ButtonLocalAssetController:
            videoUrlStr = UrlLocalTestAsset;
            break;
    }
    NSLog(@"Playing %@", videoUrlStr);
    
    NSURL *videoUrl = [NSURL URLWithString:videoUrlStr];
    AVPlayer *player = [AVPlayer playerWithURL:videoUrl];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
    controller.player = player;
    [player play];
}

- (IBAction)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue %@", [segue identifier]);
    NSString *segueId = [segue identifier];
    NSString *videoUrlStr = UrlNokiaSampleAsset;
    if ([segueId isEqualToString:SegueNokiaSampleAsset]) {
        videoUrlStr = UrlNokiaSampleAsset;
    }
    else if ([segueId isEqualToString:SegueLocalTestAsset]) {
        videoUrlStr = UrlLocalTestAsset;
    }
    NSLog(@"url is %@", videoUrlStr);
    
    PlayVideoViewController *playVideoVC = [segue destinationViewController];
    playVideoVC.videoUrlStr = videoUrlStr;
}

@end
