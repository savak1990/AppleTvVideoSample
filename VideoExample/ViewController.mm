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

NSString *const PlayOptionAVPlayerViewController = @"AVPlayerViewController";
NSString *const PlayOptionAVPlayer = @"AVPlayer";
NSString *const PlayOptionAVPlayerViewControllerVCAS = @"AVPlayerViewControllerVCAS";
NSString *const PlayOptionAVPlayerVCAS = @"AVPlayerVCAS";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *streams;
@property (nonatomic, strong) NSArray *playOptions;

@property (weak, nonatomic) IBOutlet UIButton *btnStreamChooser;
@property (weak, nonatomic) IBOutlet UITableView *tableViewStreams;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayOptionsChooser;
@property (weak, nonatomic) IBOutlet UITableView *tableViewPlayOptions;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;

@property (nonatomic, strong) NSDictionary *choosenStream;
@property (nonatomic, strong) NSString *choosenPlayOption;

@end

@implementation ViewController

@synthesize streams;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    NSString *streamsPath = [[NSBundle mainBundle] pathForResource:@"streams" ofType:@"plist"];
    streams = [NSArray arrayWithContentsOfFile:streamsPath];
    _choosenStream = [streams objectAtIndex:0];
    [_btnStreamChooser setTitle:[_choosenStream valueForKey:@"name"] forState:UIControlStateNormal];
    
    _playOptions = [NSArray arrayWithObjects:
                    PlayOptionAVPlayerViewController,
                    PlayOptionAVPlayer,
                    PlayOptionAVPlayerViewControllerVCAS,
                    PlayOptionAVPlayerVCAS, nil];
    _choosenPlayOption = [_playOptions objectAtIndex:0];
    [_btnPlayOptionsChooser setTitle:_choosenPlayOption forState:UIControlStateNormal];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%s: %@", __func__, tableView);
    if (tableView == _tableViewStreams) {
        return [streams count];
    }
    else if (tableView == _tableViewPlayOptions) {
        return [_playOptions count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId;
    NSString *titleStr;
    if (tableView == _tableViewStreams) {
        NSDictionary *stream = [streams objectAtIndex:indexPath.row];
        cellId = @"tagStreamItem";
        titleStr = [stream valueForKey:@"name"];
    } else if (tableView == _tableViewPlayOptions) {
        cellId = @"tagPlayOptionItem";
        titleStr = [_playOptions objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.textLabel.text = titleStr;
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%s index: %u", __func__, (unsigned) indexPath.row);
    
    if (tableView == _tableViewStreams) {
        _choosenStream = [streams objectAtIndex: indexPath.row];
        [_btnStreamChooser setTitle:[_choosenStream valueForKey:@"name"] forState:UIControlStateNormal];
        [_tableViewStreams resignFirstResponder];
        [_btnPlayOptionsChooser becomeFirstResponder];
        _tableViewStreams.hidden = YES;
    } else if (tableView == _tableViewPlayOptions) {
        _choosenPlayOption = [_playOptions objectAtIndex: indexPath.row];
        [_btnPlayOptionsChooser setTitle:_choosenPlayOption forState:UIControlStateNormal];
        [_tableViewPlayOptions resignFirstResponder];
        [_btnPlay becomeFirstResponder];
        _tableViewPlayOptions.hidden = YES;
    }
    
    [self setNeedsFocusUpdate];
    
//    [self startPlayViewController: urlStr];
}

- (IBAction)onStreamChooserSelect:(id)sender {
    NSLog(@"%s", __func__);
    _tableViewStreams.hidden = !_tableViewStreams.hidden;
    _tableViewPlayOptions.hidden = YES;
}

- (IBAction)onPlayOptionSelect:(id)sender {
    NSLog(@"%s", __func__);
    _tableViewPlayOptions.hidden = !_tableViewPlayOptions.hidden;
    _tableViewStreams.hidden = YES;
}

- (IBAction)onPlaySelect:(id)sender {
    NSLog(@"%s", __func__);
    
    _tableViewStreams.hidden = YES;
    _tableViewPlayOptions.hidden = YES;
    
    NSString *videoUrl = [_choosenStream valueForKey:@"url"];
    if ([_choosenPlayOption isEqualToString: PlayOptionAVPlayerViewController]) {
        [self startAVPlayerViewController: videoUrl];
    } else if ([_choosenPlayOption isEqualToString: PlayOptionAVPlayer]) {
        [self startPlayVideoViewController: videoUrl];
    } else if ([_choosenPlayOption isEqualToString: PlayOptionAVPlayerViewControllerVCAS]) {
        [self startAVPlayerViewController: videoUrl]; // TODO VCAS
    } else if ([_choosenPlayOption isEqualToString: PlayOptionAVPlayerVCAS]) {
        [self startAVPlayerViewController: videoUrl]; // TODO VCAS
    }
}

- (void) startPlayVideoViewController:(NSString *) urlStr {
    NSLog(@"%s url=%@", __func__, urlStr);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PlayVideoViewController *controller = [storyboard instantiateViewControllerWithIdentifier: @"playVideoView"];
    AVPlayer *player = [self createPlayer:urlStr];
    controller.player = player;
    [self presentViewController: controller animated: YES completion: nil];
}

- (void) startAVPlayerViewController:(NSString *) urlStr {
    NSLog(@"%s url=%@", __func__, urlStr);
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    [self presentViewController:controller animated: YES completion: nil];
    AVPlayer *player = [self createPlayer:urlStr];
    controller.player = player;
    [player play];
}

- (AVPlayer *) createPlayer:(NSString *) urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    return [AVPlayer playerWithURL:url];
}

@end
