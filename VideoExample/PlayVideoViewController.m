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

@property (nonatomic, readonly) AVPlayer *player;
@property (nonatomic, readonly) AVPlayerItem *playerItem;
@property (nonatomic, readonly) AVAsset *playerAsset;
@property (nonatomic, readonly) id periodicTimeObserver;
@property (nonatomic, readonly) AVAssetImageGenerator *generator;
@property (nonatomic, readonly) float playPosition;
@property (nonatomic, readonly) BOOL thumbnailRequestInProgress;

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
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [self.view addGestureRecognizer:panRecognizer];
    
    [_player play];
}

- (void) move:(UIPanGestureRecognizer*) sender {
    CGPoint translation = [sender translationInView:[self view]];
    float width = [self view].bounds.size.width;
    if (sender.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"GESTURE START: translationX=%.2f/%.2f velocityX=%.2f ",
        //      translation.x, width, velocity.x);
        [_player setRate:0.0];
        _playPosition = CMTimeGetSeconds([_playerItem currentTime]);
    }
    else {
        float current = CMTimeGetSeconds([_playerItem currentTime]);
        float duration = CMTimeGetSeconds([_playerItem duration]);
        _playPosition = current + duration * translation.x / width;
        UIProgressView *trickplayProgressView = [[self view] viewWithTag: ProgressViewTrickplay];
        if (duration > 0) {
            [trickplayProgressView setProgress: _playPosition / duration animated: YES];
        }
        [self generateThumbnailForTime:CMTimeMake(_playPosition, 1)];
    }
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
    
    CMTime time = CMTimeMake(1, 2);
    [self generateThumbnailForTime:time];
}

- (void) generateThumbnailForTime:(CMTime) time {
    
    if (!_thumbnailRequestInProgress) {
        NSLog(@"PlayVideoViewController.generateThumbnailForTime: %.2f", CMTimeGetSeconds(time));
        _thumbnailRequestInProgress = YES;
        NSArray *times = [NSArray arrayWithObject: [NSValue valueWithCMTime:time]];
        
        AVAssetImageGeneratorCompletionHandler handler =
            ^(CMTime requestedTime,
              CGImageRef im,
              CMTime actualTime,
              AVAssetImageGeneratorResult result,
              NSError *error) {
            
            UIImage *image = nil;
            if (result == AVAssetImageGeneratorSucceeded) {
                image = [UIImage imageWithCGImage:im];
            }
            NSLog(@"PlayVideoViewController.generateThumbnailForTime: %.2f generated: %.2f succeded: %d",
                  CMTimeGetSeconds(requestedTime), CMTimeGetSeconds(actualTime), (int) (im != nil));
            [self performSelectorOnMainThread:@selector(setVideoImage:)
                                   withObject:image
                                waitUntilDone:NO];
        };
    
        [_generator generateCGImagesAsynchronouslyForTimes:times completionHandler:handler];
    }
}

- (void) setVideoImage:(UIImage *) image {
    if (image != nil) {
        UIImageView *thumbnailView = [[self view] viewWithTag: ImageThumbnail];
        [thumbnailView setImage: image];
    }
    _thumbnailRequestInProgress = NO;
}

- (void) playbackPeriodicCallback {
    float duration = CMTimeGetSeconds([_playerItem duration]);
    _playPosition = CMTimeGetSeconds([_playerItem currentTime]);
    
    NSString *durationStr = [NSString stringWithFormat:@"%.2f", duration];
    UILabel *durationLabel = [[self view] viewWithTag:LabelDuration];
    durationLabel.text = durationStr;
    
    NSString *currentStr = [NSString stringWithFormat:@"%.2f", _playPosition];
    UILabel *currentLabel = [[self view] viewWithTag:LabelCurrent];
    [currentLabel setText: currentStr];
    
    UIProgressView *trickplayProgressView = [[self view] viewWithTag: ProgressViewTrickplay];
    if (duration > 0) {
        [trickplayProgressView setProgress: _playPosition / duration animated: YES];
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
    if ([_player rate] == 0.0) {
        __weak __typeof(_player) weakPlayer = _player;
        [_player seekToTime : CMTimeMake(_playPosition, 1)
          completionHandler : ^(BOOL isFinished) { weakPlayer.rate = 1.0; }];
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
