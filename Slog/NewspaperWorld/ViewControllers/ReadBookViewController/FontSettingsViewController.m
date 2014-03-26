//
//  FontSettingsViewController.m
//  NewspaperWorld
//

#import "FontSettingsViewController.h"
#import "NWSettings.h"
#import "Utils.h"

#define MAX_FONT_SIZE 22
#define MIN_FONT_SIZE 12

@interface FontSettingsViewController ()

- (UITableViewCell*)fontFamilyCellForTable:(UITableView*)table;

- (UITableViewCell*)fontSizeCellForTable:(UITableView*)table;

- (UITableViewCell*)textExampleCellForTable:(UITableView*)table;

- (UITableViewCell*)returnDefaultsCellForTable:(UITableView*)table;

- (void)saveOldSettings;

- (void)restoreDefaultsSettings:(id)sender;

- (void)deinitializeControls;

- (void)initializeNavigationBar;

- (IBAction)backButtonTouched:(id)sender;

- (IBAction)incrementButtonTouched:(id)sender;

- (IBAction)decrementButtonTouched:(id)sender;

- (void)updateTextExample;

- (UILabel*)exampleLabel;

- (void)reportToDelegate;

@end

@implementation FontSettingsViewController

@synthesize parentPopover = _parentPopover;
@synthesize delegate      = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _table = nil;
        _fontSizeCell = nil;
        _textExampleCell = nil;
        _oldFontSize = 0;
        _oldTextColor = nil;
        _oldFontFamily = nil;
        self.isDetailViewController = NO;
    }
    return self;
}

- (void)dealloc
{
    [self deinitializeControls];
    
    [_oldTextColor release];
    [_oldFontFamily release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeNavigationBar];
    [self updateTextExample];
    [self saveOldSettings];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self deinitializeControls];
    
    [_oldTextColor release];
    _oldTextColor = nil;
    [_oldFontFamily release];
    _oldFontFamily = nil;
}

- (void)setParentPopover:(UIPopoverController *)parentPopover
{
    [_parentPopover release];
    _parentPopover = [parentPopover retain];
    
    _parentPopover.delegate = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{     
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0)    cell = [self fontFamilyCellForTable:tableView];
    if (indexPath.row == 1)    cell = [self fontSizeCellForTable:tableView];
    if (indexPath.row == 2)    cell = [self textExampleCellForTable:tableView];
    if (indexPath.row == 3)    cell = [self returnDefaultsCellForTable:tableView];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return NSLocalizedString(@"IDS_TEXT", @"");
    return nil;
}

//- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    if (section == 0)
//        return NSLocalizedString(@"IDS_PDF_WARNING", @"");
//    return nil;
//}

#pragma mark UIPopover delegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    [self reportToDelegate];
    
    return YES;
}

#pragma mark Private methods

- (UITableViewCell*)fontFamilyCellForTable:(UITableView*)table
{
    static NSString *FontFamilyCellID   = @"FontTypeCellID";
   
    UITableViewCell* cell = [table dequeueReusableCellWithIdentifier:FontFamilyCellID];
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:FontFamilyCellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (cell)
    {
        [cell.textLabel setText:NSLocalizedString(@"IDS_FONT", @"")];
        [cell.detailTextLabel setText:[NWSettings sharedSettings].readerFontFamily];
    }
    return cell;
}

- (UITableViewCell*)fontSizeCellForTable:(UITableView*)table
{
    static NSString *FontSizeCellID     = @"FontSizeCellID";
    UITableViewCell* cell = [table dequeueReusableCellWithIdentifier:FontSizeCellID];
    if (!cell)
    {       
        cell = [[_fontSizeCell retain] autorelease];
    }
    if (cell)
    {
        [(UILabel*)[cell viewWithTag:1]  setText:NSLocalizedString(@"IDS_FONT_SIZE", @"")];
    }
    return cell;
}

- (UITableViewCell*)textExampleCellForTable:(UITableView*)table
{
    static NSString *TextExampleCellID  = @"TextExampleCellID";
    UITableViewCell* cell = [table dequeueReusableCellWithIdentifier:TextExampleCellID];
    if (!cell)
    {
        cell = [[_textExampleCell retain] autorelease];
    }
    if (cell)
    {
        [(UILabel*)[cell viewWithTag:1]  setText:NSLocalizedString(@"IDS_TEXT_EXAMPLE", @"")];
    }
    
    ((UILabel*)[cell viewWithTag:1]).textColor = [NWSettings sharedSettings].readerTextColor;            
    ((UILabel*)[cell viewWithTag:1]).backgroundColor = [NWSettings sharedSettings].readerBackgroundColor;
    
    return cell;
}

- (UITableViewCell*)returnDefaultsCellForTable:(UITableView*)table
{
    static NSString* defaultsCellID  = @"defaultsCellID";
    UITableViewCell* cell = [table dequeueReusableCellWithIdentifier:defaultsCellID];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:defaultsCellID];
        [cell autorelease];

        const CGFloat width = 150.0;
        const CGFloat heigth = 38.5;
        CGRect btnFrame = CGRectMake(0.5*(cell.frame.size.width-width), 0.5*(cell.frame.size.height-heigth), width, heigth);
        UIButton* defaultSettings = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        defaultSettings.frame = btnFrame;
        [defaultSettings setBackgroundImage:[UIImage imageNamed:@"red_btn_bg.png"] forState:UIControlStateNormal];
        [defaultSettings setTitle:NSLocalizedString(@"IDS_RETURN_DEFAULTS", @"IDS_RETURN_DEFAULTS") forState:UIControlStateNormal];
        [defaultSettings setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [defaultSettings addTarget:self action:@selector(restoreDefaultsSettings:) forControlEvents:UIControlEventTouchUpInside];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [cell addSubview:defaultSettings];
    }

    return cell;
}

- (void)saveOldSettings
{
    _oldFontSize = [NWSettings sharedSettings].readerFontSize;
    _oldTextColor = [[NWSettings sharedSettings].readerTextColor retain];
    _oldFontFamily = [[NWSettings sharedSettings].readerFontFamily retain];
}

- (void)deinitializeControls
{
    [_table release];           _table = nil;
    [_fontSizeCell release];    _fontSizeCell = nil;
    [_textExampleCell release]; _textExampleCell = nil;
}

- (void)restoreDefaultsSettings:(id)sender
{
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"IDS_INFORMATION", @"IDS_INFORMATION")
                                                    message:NSLocalizedString(@"IDS_RETURN_QUESTION", @"IDS_RETURN_QUESTION")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"IDS_NO", @"IDS_NO")
                                          otherButtonTitles:NSLocalizedString(@"IDS_YES", @"IDS_YES"), nil] autorelease];
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [NWSettings sharedSettings].readerFontSize = [NWSettings sharedSettings].readerFontSizeDefaults;
        
        [self updateTextExample];
    }
}

- (void)initializeNavigationBar
{
    self.navigationBarTitle = NSLocalizedString(@"IDS_SETTINGS", @"");    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"IDS_BACK", @"")
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(backButtonTouched:)] autorelease];        
}

- (IBAction)backButtonTouched:(id)sender
{
    [self reportToDelegate];
    
    if ([Utils isDeviceiPad])
    {
        if (self.parentPopover)
            [self.parentPopover dismissPopoverAnimated:YES];
    }
    else
        [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)incrementButtonTouched:(id)sender
{
    if ([NWSettings sharedSettings].readerFontSize < MAX_FONT_SIZE)
    {
        [NWSettings sharedSettings].readerFontSize++;
        [self updateTextExample];
    }
}

- (IBAction)decrementButtonTouched:(id)sender
{
     if ([NWSettings sharedSettings].readerFontSize > MIN_FONT_SIZE)
     {
         [NWSettings sharedSettings].readerFontSize--;
         [self updateTextExample];
     }
}

- (void)updateTextExample
{
    [[self exampleLabel] setTextColor:[NWSettings sharedSettings].readerTextColor];
    [[self exampleLabel] setFont:[UIFont fontWithName:[NWSettings sharedSettings].readerFontFamily
                                                 size:[NWSettings sharedSettings].readerFontSize]];
}

- (UILabel*)exampleLabel
{
    return (UILabel*)[_textExampleCell viewWithTag:1];
}

- (void)reportToDelegate
{
    int currentFontSize = [NWSettings sharedSettings].readerFontSize;
    UIColor* currentTextColor = [NWSettings sharedSettings].readerTextColor;
    NSString* currentFontFamily = [NWSettings sharedSettings].readerFontFamily;
    
    if ([_delegate respondsToSelector:@selector(fontSettingsViewControllerWillDismiss:fontSettingsModified:textColorModified:)])
    {
        [_delegate fontSettingsViewControllerWillDismiss:self
                                    fontSettingsModified:(currentFontSize != _oldFontSize) || ![currentFontFamily isEqualToString:_oldFontFamily]
                                       textColorModified:![currentTextColor isEqual:_oldTextColor]];
    }
}

#pragma mark Public methods

+ (FontSettingsViewController*)createViewController
{
    return [[[FontSettingsViewController alloc] initWithNibName:@"FontSettingsViewController" bundle:nil] autorelease];
}

@end
