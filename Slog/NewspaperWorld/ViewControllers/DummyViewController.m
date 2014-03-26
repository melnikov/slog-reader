//
//  DummyViewController.m
//  NewspaperWorld
//


#import "DummyViewController.h"

@interface DummyViewController ()

@end

@implementation DummyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.isDetailViewController = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mar Public methods

+ (DummyViewController*)createViewController
{
    return [[[DummyViewController alloc] initWithNibName:@"DummyViewController" bundle:nil] autorelease];
}

@end
