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

NSString *const SeguePlayWithAVPlayer = @"seguePlayWithAVPlayer";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *streams;
@property (nonatomic, strong) NSDictionary *stream;

@property (weak, nonatomic) IBOutlet UITableView *tableAVPlayerViewController;
@property (weak, nonatomic) IBOutlet UITableView *tableAVPlayer;
@end

@implementation ViewController

@synthesize streams, stream;

- (void) viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"streams" ofType:@"plist"];
    streams = [NSArray arrayWithContentsOfFile:path];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%s: %@", __func__, tableView);
    if (tableView == _tableAVPlayer) {
        NSLog(@"tableView is tableAVPlayer");
    }
    else if (tableView == _tableAVPlayerViewController) {
        NSLog(@"tableView is tableAVPlayerViewController");
    }
    return [streams count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"cell1"; // for _tableAVPlayerViewController
    if (tableView == _tableAVPlayer) {
        cellId = @"cell2";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    NSDictionary *stream = streams[indexPath.row];
    cell.textLabel.text = [stream valueForKey:@"name"];
    cell.detailTextLabel.text = [stream valueForKey:@"url"];
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *stream = streams[indexPath.row];
    NSString *urlStr = [stream valueForKey:@"url"];
    NSLog(@"%s: select %u -> %@", __func__, (unsigned) indexPath.row, urlStr);
    [self startPlayViewController: urlStr];
}

- (void) startPlayViewController:(NSString *) urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
    controller.player = player;
    [player play];
}

- (IBAction)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepareForSegue %@", [segue identifier]);
    NSString *segueId = [segue identifier];
    if ([segueId isEqualToString:SeguePlayWithAVPlayer]) {
        NSLog(@"%s: seguePlayWithAvPlayer", __func__);
        PlayVideoViewController *playVideoVC = [segue destinationViewController];
        playVideoVC.videoUrlStr = [streams[[sender tag]] valueForKey:@"url"];
    }
}

@end
