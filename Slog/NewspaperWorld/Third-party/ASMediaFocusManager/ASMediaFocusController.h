//
//  ASMediaFocusViewController.h
//  ASMediaFocusManager
//
//  Created by Philippe Converset on 21/12/12.
//  Copyright (c) 2012 AutreSphere. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASImageScrollView.h"

@protocol ASMediaFocusControllerDelegate <NSObject>

- (void)closeButtonTouched;

@end

@interface ASMediaFocusController : UIViewController

@property (strong, nonatomic) ASImageScrollView     *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView  *mainImageView;
@property (strong, nonatomic) IBOutlet UIView       *contentView;
@property (strong, nonatomic) IBOutlet UIButton     *closeButton;

@property (assign, nonatomic) BOOL isCloseButtonVisible;
@property (strong, nonatomic) NSString* closeButtonTitle;

@property (assign, nonatomic) id<ASMediaFocusControllerDelegate> delegate;

- (void)updateOrientationAnimated:(BOOL)animated;

- (IBAction)closeTouched:(id)sender;

@end
