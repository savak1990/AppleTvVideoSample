//
//  ViewController.m
//  VideoExample
//
//  Created by C: Vyacheslav Klyovan on 6/18/19.
//  Copyright © 2019 C: Vyacheslav Klyovan. All rights reserved.
//

#import "ViewController.h"
#import "PlayVideoViewController.h"
#import <AVKit/AVKit.h>

typedef NS_ENUM(NSInteger, MyExampleButtonEnum) {
    ButtonTivoAssetController = 100,
    ButtonWowzaNoFramesController = 101,
    ButtonWowzaIFramesController = 102,
    ButtonPythonController = 103,
    ButtonTivoAssetPlayer = 200,
    ButtonWowzaLocalNoFramesPlayer = 201,
    ButtonWowzaLocalIFramesPlayer = 202,
    ButtonPythonPlayer = 203
};

#define BASE_IP @"http://192.168.1.101"

NSString *const UrlTivoAsset = @"https://s3.amazonaws.com/hls-demos/nokia/index.m3u8";
NSString *const UrlWowzaNoFrames = BASE_IP@":1935/myapp/smil:test.smil/playlist.m3u8";
NSString *const UrlWowzaIFrames = BASE_IP@":1935/myapp/smil:itest.smil/playlist.m3u8";
NSString *const UrlPython = BASE_IP@":8000/index.m3u8";

NSString *const SegueIdTivoAsset = @"tivoAsset";
NSString *const SegueIdWowzaNoFrames = @"wowzaNoFramesAsset";
NSString *const SegueIdWowzaIFrames = @"wowzaIFramesAsset";
NSString *const SegueIdPython = @"pythonServerAsset";

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)onPlayVideoWithController:(UIButton *) sender {
    NSLog(@"onPlayVideoWithController: %lu", [ sender tag ]);
    
    NSString *videoUrlStr = UrlTivoAsset;
    switch ([sender tag]) {
        case ButtonTivoAssetController:
            videoUrlStr = UrlTivoAsset;
            break;
        case ButtonWowzaNoFramesController:
            videoUrlStr = UrlWowzaNoFrames;
            break;
        case ButtonWowzaIFramesController:
            videoUrlStr = UrlWowzaIFrames;
            break;
        case ButtonPythonController:
            videoUrlStr = UrlPython;
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
    NSString *videoUrlStr = UrlTivoAsset;
    if ([segueId isEqualToString:SegueIdTivoAsset]) {
        videoUrlStr = UrlTivoAsset;
    }
    else if ([segueId isEqualToString:SegueIdWowzaNoFrames]) {
        videoUrlStr = UrlWowzaNoFrames;
    }
    else if ([segueId isEqualToString:SegueIdWowzaIFrames]) {
        videoUrlStr = UrlWowzaIFrames;
    }
    else if ([segueId isEqualToString:SegueIdPython]) {
        videoUrlStr = UrlPython;
    }
    NSLog(@"url is %@", videoUrlStr);
    
    PlayVideoViewController *playVideoVC = [segue destinationViewController];
    playVideoVC.videoUrlStr = videoUrlStr;
}

@end
