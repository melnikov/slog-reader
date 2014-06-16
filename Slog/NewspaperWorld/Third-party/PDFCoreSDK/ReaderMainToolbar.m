//
//	ReaderMainToolbar.m
//	Reader v2.6.1
//
//	Created by Julius Oklamcak on 2011-07-01.
//	Copyright © 2011-2012 Julius Oklamcak. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderConstants.h"
#import "ReaderMainToolbar.h"
#import "ReaderDocument.h"
#import "Constants.h"
#import <MessageUI/MessageUI.h>
#import "Utils.h"

@implementation ReaderMainToolbar
{
	UIButton *markButton;

	UIImage *markImageN;
	UIImage *markImageY;
}

#pragma mark Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f

#define DONE_BUTTON_WIDTH 56.0f
#define THUMBS_BUTTON_WIDTH 40.0f
#define PRINT_BUTTON_WIDTH 40.0f
#define EMAIL_BUTTON_WIDTH 40.0f
#define MARK_BUTTON_WIDTH 40.0f

#define TITLE_HEIGHT 28.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ReaderMainToolbar instance methods

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame document:nil];
}

- (id)initWithFrame:(CGRect)frame document:(ReaderDocument *)object
{
	assert(object != nil); // Must have a valid ReaderDocument

	if ((self = [super initWithFrame:frame]))
	{
        UIBarButtonItem *flexibleSpaceLeft1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        UILabel* tLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width/2, self.bounds.size.height)];
        tLabel.backgroundColor = [UIColor clearColor];
        tLabel.textColor = RGB(136, 24, 17);
        tLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        tLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tLabel.textAlignment = UITextAlignmentCenter;
        
        _titleView = [[UIBarButtonItem alloc] initWithCustomView:tLabel];
        UIBarButtonItem *flexibleSpaceLeft2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIImage* bookMarkImg = [UIImage imageNamed:@"bookMark.png"];
        UIBarButtonItem *flagButton = [[UIBarButtonItem alloc] initWithImage:bookMarkImg style:UIBarButtonItemStylePlain target:self action:@selector(markButtonTapped:)];
		flagButton.tintColor = RGB(136, 24, 17);
        
        UIImage* thumbsImg = [UIImage imageNamed:@"Reader-Thumbs"];
        UIBarButtonItem *thumbsButton = [[UIBarButtonItem alloc] initWithImage:thumbsImg style:UIBarButtonItemStylePlain target:self action:@selector(thumbsButtonTapped:)];
		thumbsButton.tintColor = RGB(136, 24, 17);
        
        _buttons = [NSArray arrayWithObjects:flexibleSpaceLeft1, _titleView, flexibleSpaceLeft2, thumbsButton, flagButton, nil];
        [self setItems:_buttons];
	}

	return self;
}

- (void)setTitle:(NSString*)title
{
    if (title) {
        ((UILabel*)_titleView.customView).text = title;
    }
}

- (void)setBookmarkState:(BOOL)state
{
#if (READER_BOOKMARKS == TRUE) // Option

	if (state != markButton.tag) // Only if different state
	{
		if (self.hidden == NO) // Only if toolbar is visible
		{
			UIImage *image = (state ? markImageY : markImageN);

			[markButton setImage:image forState:UIControlStateNormal];
		}

		markButton.tag = state; // Update bookmarked state tag
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)updateBookmarkImage
{
#if (READER_BOOKMARKS == TRUE) // Option

	if (markButton.tag != NSIntegerMin) // Valid tag
	{
		BOOL state = markButton.tag; // Bookmarked state

		UIImage *image = (state ? markImageY : markImageN);

		[markButton setImage:image forState:UIControlStateNormal];
	}

	if (markButton.enabled == NO) markButton.enabled = YES;

#endif // end of READER_BOOKMARKS Option
}

- (void)hideToolbar
{
	if (self.hidden == NO)
	{
		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.alpha = 0.0f;
			}
			completion:^(BOOL finished)
			{
				self.hidden = YES;
			}
		];
	}
}

- (void)showToolbar
{
	if (self.hidden == YES)
	{
		[self updateBookmarkImage]; // First

		[UIView animateWithDuration:0.25 delay:0.0
			options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
			animations:^(void)
			{
				self.hidden = NO;
				self.alpha = 1.0f;
			}
			completion:NULL
		];
	}
}

#pragma mark UIButton action methods

- (void)doneButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self doneButton:button];
}

- (void)thumbsButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self thumbsButton:button];
}

- (void)printButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self printButton:button];
}

- (void)emailButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self emailButton:button];
}

- (void)markButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self markButton:button];
}

@end
