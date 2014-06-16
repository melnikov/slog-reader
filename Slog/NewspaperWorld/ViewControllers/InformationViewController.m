//
//  InformationViewController.m
//  NewspaperWorld
//

#import "InformationViewController.h"
#import "Utils.h"

@interface InformationViewController (Private)

@end

@implementation InformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _textView = nil;
        _informationTitle = nil;
        _informationText = nil;
        self.isDetailViewController = NO;
    }
    return self;
}

- (void)dealloc
{
    [_textView release];
    [_informationText release];
    [_informationTitle  release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     
    self.navigationItem.title = _informationTitle;
    [_textView setText:_informationText];
	
	background.image = [UIImage imageNamed:@"background_vert.jpg"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark Public methods

+ (InformationViewController*)createViewController
{
    return [[[InformationViewController alloc] initWithNibName:@"InformationViewController" bundle:nil] autorelease];
}

+ (InformationViewController*)informationWithTitle:(NSString*)title text:(NSString*)text;
{
    InformationViewController* info = [InformationViewController createViewController];
    if ([info initializeWithTitle:title text:text])
        return info;
    return nil;
}

- (BOOL)initializeWithTitle:(NSString*)title text:(NSString*)text
{
    if (!title || !text)
        return NO;
    
    [_informationTitle release];
    _informationTitle = [title retain];
     
    [_informationText release];
    _informationText = [text retain];
    return YES;
}

@end
