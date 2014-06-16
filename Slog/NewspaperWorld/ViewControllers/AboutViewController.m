//
//  AboutViewController.m
//  NewspaperWorld
//

#import "AboutViewController.h"

@interface AboutViewController (Private)

- (void)initializeDefaults;

- (void)deinitialize;

@end

@implementation AboutViewController

#pragma mark Memory management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self initializeDefaults];
        self.isDetailViewController = NO;
    }
    return self;
}

- (void)dealloc
{
    [self deinitialize];
    [_descriptionText release];
    [super dealloc];
}

#pragma mark View life-cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"IDS_ABOUT_APP", @"");
    [_applicationNameLabel setText:[[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleDisplayName"]];
    NSString* versionString =  [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    [_applicationVersionLabel setText:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"IDS_VERSION",@""), versionString]];
    [_applicationCopyrightsLabel setText:NSLocalizedString(@"IDS_COPYRIGHT", @"")];
   
    [_applicationDescriptionView setText:_descriptionText];
	
	background.image = [UIImage imageNamed:@"background_vert.jpg"];
}

- (void)viewDidUnload
{
    [self deinitialize];
    
    [super viewDidUnload];
}

#pragma mark Public methods

+ (AboutViewController*)createViewController
{
    return [[[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil] autorelease];
}

- (BOOL)initializeWithDescription:(NSString*)text
{
    if (!text)
        return NO;
    
    [_descriptionText release];
    _descriptionText = [text copy];
    
    return YES;
}

#pragma mark Private methods

- (void)initializeDefaults
{
    _applicationNameLabel = nil;
    _applicationVersionLabel = nil;
    _applicationCopyrightsLabel = nil;
    _applicationDescriptionView = nil;
    _applicationLogoView = nil;
    _descriptionText = nil;
}

- (void)deinitialize
{
    [_applicationNameLabel release];        _applicationNameLabel = nil;
    [_applicationVersionLabel release];     _applicationVersionLabel = nil;
    [_applicationCopyrightsLabel release];  _applicationCopyrightsLabel = nil;
    [_applicationDescriptionView release];  _applicationDescriptionView = nil;
    [_applicationLogoView release];         _applicationLogoView = nil;
}

@end
