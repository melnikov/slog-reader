//
//  SplashViewController.m
//  NewspaperWorld
//

#import "SplashViewController.h"
#import "Utils.h"

static SplashViewController* splashInstance = nil;

#define WINDOW_SIZE_IPHONE_PORTRAIT   CGSizeMake(320.0f, 460.0f)
#define WINDOW_SIZE_IPHONE_LANDSCAPE  CGSizeMake(480.0f, 300.0f)
#define WINDOW_SIZE_IPAD_PORTRAIT     CGSizeMake(768.0f, 1004.0f)
#define WINDOW_SIZE_IPAD_LANDSCAPE    CGSizeMake(1024.0f, 748.0f)
#define WINDOW_SIZE_IPHONE5_PORTRAIT  CGSizeMake(320.0f, 548.0f)
#define WINDOW_SIZE_IPHONE5_LANDSCAPE CGSizeMake(568.0f, 300.0f)

static void singleton_remover()
{
    [splashInstance release];
}

@interface SplashViewController(Private)

- (void)updateDescriptionPosition:(UIInterfaceOrientation)orientation;

- (void)beginProgress;

- (void)stopProgress;

@end


@implementation SplashViewController

@synthesize visible = _visible, descriptionText = _descriptionText;

#pragma mark Memory management

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _activityIndicator = nil;
        _splashImageView = nil;
        _loadDescriptionLabel = nil;
        _visible = NO;
        _descriptionText = nil;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _activityIndicator = nil;
        _splashImageView = nil;
        _loadDescriptionLabel = nil;
        _visible = NO;
        _descriptionText = nil;
        self.isDetailViewController = NO;
    }
    return self;
}

- (void)dealloc
{
    _visible = NO;
    [_activityIndicator     release];
    [_splashImageView       release];
    [_loadDescriptionLabel  release];
    
    [super dealloc];
}

#pragma mark View life cycle

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    _splashImageView = [[UIImageView alloc] init];
    [self.view addSubview:_splashImageView];
  
    _loadDescriptionLabel = [[UILabel alloc] init];
    _loadDescriptionLabel.backgroundColor = [UIColor clearColor];
    _loadDescriptionLabel.textColor = [UIColor whiteColor];
    
    [self.view addSubview:_loadDescriptionLabel];
        
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:_activityIndicator];
    
    [self updateDescriptionPosition:self.statusBarOrientation]; //Default is portrait
}

- (void)viewDidUnload
{
    [_activityIndicator release];       _activityIndicator = nil;
    [_splashImageView release];         _splashImageView = nil;
    [_loadDescriptionLabel release];    _loadDescriptionLabel = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([Utils isDeviceiPad])
    {
        return YES;
    }
    else
    {
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateDescriptionPosition:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark Private
- (void)stopProgress
{
    _visible = NO;
    [_activityIndicator stopAnimating];
}

- (void)beginProgress
{
    _visible = YES;
    [_activityIndicator setHidden:NO];
    [_activityIndicator startAnimating];
}

#pragma mark Property accessory

- (void)updateDescriptionPosition:(UIInterfaceOrientation)orientation
{
    //New
    
    CGSize windowSize = CGSizeZero;
    
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        if ([Utils isDeviceiPad])
        {
            _splashImageView.image = [UIImage imageNamed:@"Default-Portrait~ipad.png"];
            windowSize = WINDOW_SIZE_IPAD_PORTRAIT;
        }
        else
        {
            if ([UIScreen mainScreen].bounds.size.height == 568)
            {
                _splashImageView.image = [UIImage imageNamed: @"Default-568h.png"];
                
                windowSize = WINDOW_SIZE_IPHONE5_PORTRAIT;
            }
            if ([UIScreen mainScreen].bounds.size.height == 480)
            {
                _splashImageView.image = [UIImage imageNamed: @"Default~iphone.png"];
                windowSize = WINDOW_SIZE_IPHONE_PORTRAIT;
            }
        }
    }
    else
    {
        if ([Utils isDeviceiPad])
        {
            _splashImageView.image = [UIImage imageNamed:@"Default-Landscape~ipad.png"];
            windowSize = WINDOW_SIZE_IPAD_LANDSCAPE;
        }
        else
        {
            //Not applicable variant
            _splashImageView.image = nil;

            if ([UIScreen mainScreen].bounds.size.height == 568)
            {
                windowSize = WINDOW_SIZE_IPHONE5_PORTRAIT;
            }
            if ([UIScreen mainScreen].bounds.size.height == 480)
            {
                windowSize = WINDOW_SIZE_IPHONE_LANDSCAPE;
            }
        }
    }
    
    int marigniOS7 = 0;
    if ([Utils isiOS7]){
        marigniOS7 = 20;
    }
    
    CGRect imageFrame = CGRectMake(0.0f, 0.0f, windowSize.width, windowSize.height+marigniOS7);
     _splashImageView.frame = imageFrame;
    
    CGSize fitSize = [_loadDescriptionLabel.text sizeWithFont:_loadDescriptionLabel.font];
    
    _loadDescriptionLabel.frame = CGRectMake(windowSize.width / 2 - fitSize.width / 2,
                                             windowSize.height+marigniOS7 - fitSize.height - 20.0f,
                                             fitSize.width,
                                             fitSize.height);
    CGFloat spinnerOriginY = _loadDescriptionLabel.frame.origin.y + (_loadDescriptionLabel.frame.size.height / 2) - (_activityIndicator.frame.size.height / 2);
    _activityIndicator.frame = CGRectMake(_loadDescriptionLabel.frame.origin.x - _activityIndicator.frame.size.width - 20.0f, spinnerOriginY, _activityIndicator.frame.size.width, _activityIndicator.frame.size.height);
}

- (void)setDescriptionText:(NSString*)text
{
    [_loadDescriptionLabel setText:text];
    [self updateDescriptionPosition:self.statusBarOrientation];
}

#pragma mark Public implementation

+ (void)showSplashWithText:(NSString*)text
{
    if (!splashInstance)
    {
        splashInstance = [[SplashViewController alloc] init];
        atexit(singleton_remover);
    }
    if (!splashInstance.visible)
    {
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        if (!window)
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        
        if ([[UIDevice currentDevice].systemVersion floatValue] > 5.9f)
        {
            [splashInstance view];
            window.rootViewController = splashInstance;
            [splashInstance beginProgress];
        }
        else
        {
            [window addSubview:splashInstance.view];
            [splashInstance beginProgress];
        }
    }
    if (text)
    {
        splashInstance.descriptionText = text;
        [splashInstance beginProgress];
    }   
}

+ (void)hideSplash
{
    [splashInstance stopProgress];
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0f)
    {
        [splashInstance.view removeFromSuperview];
    }
}

@end
