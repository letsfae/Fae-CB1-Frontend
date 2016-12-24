//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQAudioMediaViewAttributesCustom.h"

#import <JSQMessagesViewController/UIImage+JSQMessages.h>
#import <JSQMessagesViewController/UIColor+JSQMessages.h>

@implementation JSQAudioMediaViewAttributesCustom

- (instancetype)initWithPlayButtonImage:(UIImage *)playButtonImage
                       pauseButtonImage:(UIImage *)pauseButtonImage
                              labelFont:(UIFont *)labelFont
                  showFractionalSecodns:(BOOL)showFractionalSeconds
                        backgroundColor:(UIColor *)backgroundColor
                              tintColor:(UIColor *)tintColor
                          controlInsets:(UIEdgeInsets)controlInsets
                         controlPadding:(CGFloat)controlPadding
                          audioCategory:(NSString *)audioCategory
                   audioCategoryOptions:(AVAudioSessionCategoryOptions)audioCategoryOptions {
    NSParameterAssert(playButtonImage != nil);
    NSParameterAssert(pauseButtonImage != nil);
    NSParameterAssert(labelFont != nil);
    NSParameterAssert(backgroundColor != nil);
    NSParameterAssert(tintColor != nil);
    NSParameterAssert(audioCategory != nil);

    self = [super init];
    if (self) {
        _playButtonImage = playButtonImage;
        _pauseButtonImage = pauseButtonImage;
        _labelFont = labelFont;
        _showFractionalSeconds = showFractionalSeconds;
        _backgroundColor = backgroundColor;
        _tintColor = tintColor;
        _controlInsets = controlInsets;
        _controlPadding = controlPadding;
        _audioCategory = audioCategory;
        _audioCategoryOptions = audioCategoryOptions;
    }
    return self;
}

- (instancetype)init
{
    UIColor *tintColor = [[UIColor alloc] initWithRed:249.0/255 green:90.0/255 blue:90.0/255 alpha:1];
    AVAudioSessionCategoryOptions options = AVAudioSessionCategoryOptionDuckOthers
    | AVAudioSessionCategoryOptionDefaultToSpeaker
    | AVAudioSessionCategoryOptionAllowBluetooth;

    return [self initWithPlayButtonImage:[[UIImage imageNamed: @"playButton_red.png"]
                jsq_imageMaskedWithColor:tintColor]
                        pauseButtonImage:[[UIImage imageNamed: @"pauseButton_red.png"]jsq_imageMaskedWithColor:tintColor]
                               labelFont:[UIFont systemFontOfSize:12]
                   showFractionalSecodns:NO
                         backgroundColor:[UIColor jsq_messageBubbleLightGrayColor]
                               tintColor:tintColor
                           controlInsets:UIEdgeInsetsMake(6, 6, 6, 18)
                          controlPadding:6
                           audioCategory:@"AVAudioSessionCategoryPlayback"
                    audioCategoryOptions:options];
}

- (void)setPlayButtonImage:(UIImage *)playButtonImage
{
    NSParameterAssert(playButtonImage != nil);
    _playButtonImage = playButtonImage;
}

- (void)setPauseButtonImage:(UIImage *)pauseButtonImage
{
    NSParameterAssert(pauseButtonImage != nil);
    _pauseButtonImage = pauseButtonImage;
}

- (void)setLabelFont:(UIFont *)labelFont
{
    NSParameterAssert(labelFont != nil);
    _labelFont = labelFont;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    NSParameterAssert(backgroundColor != nil);
    _backgroundColor = backgroundColor;
}

- (void)setTintColor:(UIColor *)tintColor
{
    NSParameterAssert(tintColor != nil);
    _tintColor = tintColor;
}

- (void)setAudioCategory:(NSString *)audioCategory
{
    NSParameterAssert(audioCategory != nil);
    _audioCategory = audioCategory;
}

@end
