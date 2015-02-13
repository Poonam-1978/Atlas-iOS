//
//  LYRUIConversationCollectionViewHeader.m
//  Atlas
//
//  Created by Kevin Coleman on 9/10/14.
//  Copyright (c) 2015 Layer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "LYRUIConversationCollectionViewHeader.h"
#import "LYRUIConstants.h"
#import "LYRUIMessagingUtilities.h"

@interface LYRUIConversationCollectionViewHeader ()

@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *participantLabel;

@end

@implementation LYRUIConversationCollectionViewHeader

NSString *const LYRUIConversationViewHeaderIdentifier = @"LYRUIConversationViewHeaderIdentifier";

CGFloat const LYRUIConversationViewHeaderParticipantLeftPadding = 50;
CGFloat const LYRUIConversationViewHeaderHorizontalPadding = 10;
CGFloat const LYRUIConversationViewHeaderTopPadding = 18;
CGFloat const LYRUIConversationViewHeaderDateBottomPadding = 18;
CGFloat const LYRUIConversationViewHeaderParticipantNameBottomPadding = 2;
CGFloat const LYRUIConversationViewHeaderEmptyHeight = 2;

+ (LYRUIConversationCollectionViewHeader *)sharedHeader
{
    static LYRUIConversationCollectionViewHeader *_sharedHeader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHeader = [LYRUIConversationCollectionViewHeader new];
    });
    return _sharedHeader;
}

+ (void)initialize
{
    LYRUIConversationCollectionViewHeader *proxy = [self appearance];
    proxy.participantLabelTextColor = [UIColor grayColor];
    proxy.participantLabelFont = [UIFont systemFontOfSize:10];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self lyr_commonInit];
    }
    return self;
}

- (void)lyr_commonInit
{
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.dateLabel];
    
    self.participantLabel = [[UILabel alloc] init];
    self.participantLabel.font = _participantLabelFont;
    self.participantLabel.textColor = _participantLabelTextColor;
    self.participantLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.participantLabel];
    
    [self configureDateLabelConstraints];
    [self configureParticipantLabelConstraints];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.dateLabel.text = nil;
    self.participantLabel.text = nil;
}

- (void)updateWithAttributedStringForDate:(NSAttributedString *)date
{
    if (!date) return;
    self.dateLabel.attributedText = date;
}

- (void)updateWithParticipantName:(NSString *)participantName
{
    if (participantName.length) {
        self.participantLabel.text = participantName;
    } else {
        self.participantLabel.text = @"Unknown User";
    }
}

- (void)setParticipantLabelFont:(UIFont *)participantLabelFont
{
    _participantLabelFont = participantLabelFont;
    self.participantLabel.font = participantLabelFont;
}

- (void)setParticipantLabelTextColor:(UIColor *)participantLabelTextColor
{
    _participantLabelTextColor = participantLabelTextColor;
    self.participantLabel.textColor = participantLabelTextColor;
}

+ (CGFloat)headerHeightWithDateString:(NSAttributedString *)dateString participantName:(NSString *)participantName inView:(UIView *)view
{
    if (!dateString.length && !participantName.length) return LYRUIConversationViewHeaderEmptyHeight;
    
    // Temporarily adding the view to the hierarchy so that UIAppearance property values will be set based on containment.
    LYRUIConversationCollectionViewHeader *header = [self sharedHeader];
    [view addSubview:header];
    [header removeFromSuperview];
    
    CGFloat height = 0;
    height += LYRUIConversationViewHeaderTopPadding;
    
    if (dateString.length) {
        [header updateWithAttributedStringForDate:dateString];
        CGSize dateSize = [header.dateLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        height += dateSize.height + LYRUIConversationViewHeaderDateBottomPadding;
    }
    
    if (participantName.length) {
        [header updateWithParticipantName:participantName];
        CGSize participantSize = [header.participantLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        height += participantSize.height + LYRUIConversationViewHeaderParticipantNameBottomPadding;
    }
    
    return height;
}

- (void)configureDateLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:LYRUIConversationViewHeaderTopPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    // To work around an apparent system bug that initially requires the view to have zero width, instead of a required priority, we use a priority one higher than the content compression resistance.
    NSLayoutConstraint *dateLabelLeftConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:LYRUIConversationViewHeaderHorizontalPadding];
    dateLabelLeftConstraint.priority = UILayoutPriorityDefaultHigh + 1;
    [self addConstraint:dateLabelLeftConstraint];
    
    NSLayoutConstraint *dateLabelRightConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-LYRUIConversationViewHeaderHorizontalPadding];
    dateLabelRightConstraint.priority = UILayoutPriorityDefaultHigh + 1;
    [self addConstraint:dateLabelRightConstraint];
}

- (void)configureParticipantLabelConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.participantLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-LYRUIConversationViewHeaderParticipantNameBottomPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.participantLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:LYRUIConversationViewHeaderParticipantLeftPadding]];
    
    // To work around an apparent system bug that initially requires the view to have zero width, instead of a required priority, we use a priority one higher than the content compression resistance.
    NSLayoutConstraint *participantLabelRightConstraint = [NSLayoutConstraint constraintWithItem:self.participantLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-LYRUIConversationViewHeaderHorizontalPadding];
    participantLabelRightConstraint.priority = UILayoutPriorityDefaultHigh + 1;
    [self addConstraint:participantLabelRightConstraint];
}


@end
