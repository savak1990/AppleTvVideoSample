//
//  PlayVideoViewController.m
//  VideoExample
//
//  Created by C: Vyacheslav Klyovan on 6/20/19.
//  Copyright © 2019 C: Vyacheslav Klyovan. All rights reserved.
//

#import "PlayVideoViewController.h"
#import "PlayerView.h"
#import "ButtonTagEnum.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface PlayVideoViewController ()

@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;
@property (nonatomic) AVAsset *playerAsset;
@property (nonatomic) id periodicTimeObserver;
@property (nonatomic) AVAssetImageGenerator *generator;

@end

@implementation PlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"PlayVideoViewController.viewDidLoad: videoUrl=%@", _videoUrlStr);
    
    PlayerView *playerView = (PlayerView *)[self view];
    
    NSURL *nsVideoUrl = [NSURL URLWithString:_videoUrlStr];
    _player = [AVPlayer playerWithURL: nsVideoUrl];
    _playerItem = [_player currentItem];
    _playerAsset = [_playerItem asset];
    
    [_playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [_player addObserver:self forKeyPath:@"rate" options:0 context:nil];
    
    playerView.player = _player;
    
    UISwipeGestureRecognizer *recognizer =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(swipeRight:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:recognizer];
    
    [_player play];
}

- (void) swipeRight:(UISwipeGestureRecognizer *) sender {
    NSLog(@"Swipe works");
}

- (void) viewDidDisappear:(BOOL)animated {
    [_player removeTimeObserver:_periodicTimeObserver];
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                        context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        [self onReadyToPlay];
    }
    else if ([keyPath isEqualToString:@"rate"]) {
        [self onRateUpdated];
    }
}

- (void) onReadyToPlay {
    NSLog(@"PlayVideoViewController.onReadyToPlay");
    
    NSLog(@"PlayVideoViewController: trickplay capabilities: "
          "forward: %d | %d  reverse: %d | %d | %d  step: %d | %d",
          (int) [_playerItem canPlayFastForward], (int) [_playerItem canPlaySlowForward],
          (int) [_playerItem canPlayReverse], (int) [_playerItem canPlayFastReverse],
          (int) [_playerItem canPlaySlowReverse], (int) [_playerItem canStepForward],
          (int) [_playerItem canStepBackward]);
    
    _generator = [[AVAssetImageGenerator alloc] initWithAsset:_playerAsset];
    _generator.appliesPreferredTrackTransform = TRUE;
    
    __weak __typeof(self) weakSelf = self;
    CMTime interval = CMTimeMakeWithSeconds(0.25, NSEC_PER_SEC);
    _periodicTimeObserver = [ _player addPeriodicTimeObserverForInterval:interval
                                                                   queue:nil
                                                              usingBlock:
                             ^(CMTime time) {
                                 [weakSelf playbackPeriodicCallback];
                             }];
    
    CMTime time = CMTimeMake(3, 2);
    [self generateThumbnailForTime:time];
}

- (void) generateThumbnailForTime:(CMTime) time {
    NSArray *times = [NSArray arrayWithObject: [NSValue valueWithCMTime:time]];
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
        }else{
            NSLog(@"img generated: time: %.2f actualTime: %.2f",
                  CMTimeGetSeconds(requestedTime), CMTimeGetSeconds(actualTime));
            NSLog(@"img generated: %@", im);
            UIImage *image = [UIImage imageWithCGImage:im];
            [self performSelectorOnMainThread:@selector(setVideoImage:)
                                   withObject:image
                                waitUntilDone:NO];
        }
    };
    
    [_generator generateCGImagesAsynchronouslyForTimes:times completionHandler:handler];
}

- (void) setVideoImage:(UIImage *) image {
    UIImageView *thumbnailView = [[self view] viewWithTag: ImageThumbnail];
    [thumbnailView setImage: image];
}

- (void) playbackPeriodicCallback {
    NSLog(@"PlayVideoViewController.playbackPeriodicCallback");
    
    float duration = CMTimeGetSeconds([_playerItem duration]);
    float current = CMTimeGetSeconds([_playerItem currentTime]);
    
    NSString *durationStr = [NSString stringWithFormat:@"%.2f", duration];
    UILabel *durationLabel = [[self view] viewWithTag:LabelDuration];
    durationLabel.text = durationStr;
    
    NSString *currentStr = [NSString stringWithFormat:@"%.2f", current];
    UILabel *currentLabel = [[self view] viewWithTag:LabelCurrent];
    [currentLabel setText: currentStr];
    
    UIProgressView *trickplayProgressView = [[self view] viewWithTag: ProgressViewTrickplay];
    if (duration > 0) {
        [trickplayProgressView setProgress: current / duration animated: YES];
    }
    
    NSString *seekableTimeRangesStr = [self getReadableTimeRanges:[_playerItem seekableTimeRanges]];
    UILabel *seekableTimeRangesLabel = [[self view] viewWithTag: LabelSeekableTimeRanges];
    [seekableTimeRangesLabel setText: seekableTimeRangesStr];
    
    NSString *loadedTimeRangesStr = [self getReadableTimeRanges:[_playerItem loadedTimeRanges]];
    UILabel *loadedTimeRangesLabel = [[self view] viewWithTag: LabelLoadedTimeRanges];
    [loadedTimeRangesLabel setText: loadedTimeRangesStr];
}

- (IBAction)onPlayPausePressed:(UIButton *)sender {
    NSLog(@"PlayVideoViewController.onPlayPausePressed");
    [self generateThumbnailForTime:[_playerItem currentTime]];
    if ([_player rate] == 0.0) {
        _player.rate = 1.0;
    }
    else {
        _player.rate = 0.0;
    }
}

- (void) onRateUpdated {
    NSLog(@"PlayVideoViewController.onRateUpdated rate=%f", [_player rate]);
    id playPauseButton = [[self view] viewWithTag: ButtonPlayPause];
    if ([_player rate] == 0.0) {
        [playPauseButton setTitle: @"Play" forState:UIControlStateNormal];
    }
    else {
        [playPauseButton setTitle: @"Pause" forState:UIControlStateNormal];
    }
}

- (NSString *) getReadableTimeRanges:(NSArray*) timeRanges {
    NSMutableString *str = [NSMutableString string];
    for (NSValue *value in timeRanges) {
        CMTimeRange range = [value CMTimeRangeValue];
        CMTime start = range.start;
        CMTime end = CMTimeRangeGetEnd(range);
        [str appendFormat:@" %.2f-%.2f", CMTimeGetSeconds(start), CMTimeGetSeconds(end)];
    }
    return str;
}

@end
