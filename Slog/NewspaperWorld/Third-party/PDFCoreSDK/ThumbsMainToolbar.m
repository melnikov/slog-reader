//
//	ThumbsMainToolbar.m
//	Reader v2.6.0
//
//	Created by Julius Oklamcak on 2011-09-01.
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
#import "ThumbsMainToolbar.h"
#import "Constants.h"

@implementation ThumbsMainToolbar

#pragma mark Constants

#define BUTTON_X 8.0f
#define BUTTON_Y 8.0f
#define BUTTON_SPACE 8.0f
#define BUTTON_HEIGHT 30.0f

#define DONE_BUTTON_WIDTH 56.0f
#define SHOW_CONTROL_WIDTH 78.0f

#define TITLE_HEIGHT 28.0f

#pragma mark Properties

@synthesize delegate;

#pragma mark ThumbsMainToolbar instance methods

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame title:nil];
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title
{
	if ((self = [super initWithFrame:frame]))
	{
        UIBarButtonItem *flexibleSpaceLeft1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        UILabel* tLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width/2, self.bounds.size.height)];
        tLabel.backgroundColor = [UIColor clearColor];
        tLabel.textColor = RGB(136, 24, 17);
        tLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        tLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tLabel.textAlignment = UITextAlignmentCenter;
        tLabel.text = title;
        
        _titleViewItem = [[UIBarButtonItem alloc] initWithCustomView:tLabel];
        UIBarButtonItem *flexibleSpaceLeft2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIImage* bookMarkImg = [UIImage imageNamed:@"bookMark.png"];
        UIBarButtonItem *flagButton = [[UIBarButtonItem alloc] initWithImage:bookMarkImg style:UIBarButtonItemStylePlain target:self action:@selector(flagButtonCb)];
		flagButton.tintColor = RGB(136, 24, 17);
        
        UIImage* thumbsImg = [UIImage imageNamed:@"Reader-Thumbs"];
        UIBarButtonItem *thumbsButton = [[UIBarButtonItem alloc] initWithImage:thumbsImg style:UIBarButtonItemStylePlain target:self action:@selector(thumbsButtonCb)];
		thumbsButton.tintColor = RGB(136, 24, 17);
        
        NSArray* buttons = [NSArray arrayWithObjects:flexibleSpaceLeft1, _titleViewItem, flexibleSpaceLeft2, thumbsButton, flagButton, nil];
        [self setItems:buttons];
	}

	return self;
}

- (void)flagButtonCb
{
    [self showControlTapped:1];
}

- (void)thumbsButtonCb
{
    [self showControlTapped:0];
}

#pragma mark UISegmentedControl action methods

- (void)showControlTapped:(unsigned)control
{
	[delegate tappedInToolbar:self showControl:control];
}

#pragma mark UIButton action methods

- (void)doneButtonTapped:(UIButton *)button
{
	[delegate tappedInToolbar:self doneButton:button];
}

@end
