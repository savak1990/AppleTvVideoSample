//
//  ButtonTagEnum.h
//  VideoExample
//
//  Created by C: Vyacheslav Klyovan on 6/21/19.
//  Copyright © 2019 C: Vyacheslav Klyovan. All rights reserved.
//

#ifndef ButtonTagEnum_h
#define ButtonTagEnum_h

typedef NS_ENUM(NSInteger, ViewTagEnum) {
    ButtonNokiaAssetController = 100,
    ButtonLocalAssetController = 101,
    ButtonNokiaAssetPlayer = 200,
    ButtonLocalAssetPlayer = 201,
    ButtonPlayPause = 300,
    ProgressViewTrickplay = 301,
    LabelDuration = 302,
    LabelCurrent = 303,
    LabelSeekableTimeRanges = 304,
    LabelLoadedTimeRanges = 305,
    ImageThumbnail = 306
};

#endif /* ButtonTagEnum_h */
