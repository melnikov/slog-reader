//
//  UIStyleManager.m

#import "UIStyleManager.h"
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>

static UIStyleManager* instance_ = nil;

@interface UIStyleManager()

- (void)applyStyleForButton:(UIButton*)button Style:(NSString*)styleName;
- (void)applyStyleForTextField:(UITextField*)textField Style:(NSString*)styleName;
- (void)applyStyleForTextView:(UITextView*)textView Style:(NSString*)styleName;
- (void)applyStyleForCell:(UITableViewCell*)cell Style:(NSString*)styleName;
- (void)applyStyleForSwitch:(UISwitch*)switchView Style:(NSString*)styleName;
- (void)applyStyleForTable:(UITableView*)table Style:(NSString*)styleName;
- (void)applyStyleForLabel:(UILabel*)label Style:(NSString*)styleName;
- (void)applyStyleForView:(UIView*)view Style:(NSString*)styleName;
- (void)applyStyleForBar:(UINavigationBar*)bar Style:(NSString*)styleName;
- (void)applyStyleForSegmentedControl:(UISegmentedControl*)view Style:(NSString*)styleName;

- (UIColor *)colorWithString:(NSString *) stringToConvert;

@end

@implementation UIStyleManager

+ (UIStyleManager*)instance {
  if (instance_ == nil) {
    instance_ = [[UIStyleManager alloc] init];
  }
  return instance_;
}

- (id)init {
  self = [super init];
  if (self) {
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    plistPath = [[NSBundle mainBundle] pathForResource:@"UIStyles" ofType:@"plist"];
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    contentOfStylesFile = (NSMutableDictionary *)[[NSPropertyListSerialization propertyListFromData:plistXML
                                                                                   mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                                             format:&format
                                                                                   errorDescription:&errorDesc] retain];
  }
  return self;
}

- (void)applyStyle:(NSString*)styleName toView:(UIView *)view {
  if (view == nil)
    return;
  
  if ([view isKindOfClass:NSClassFromString(@"UIButton")]) {
    [self applyStyleForButton:(UIButton *)view Style:styleName];
  }
  else if ([view isKindOfClass:NSClassFromString(@"UITextField")]) {
    [self applyStyleForTextField:(UITextField *)view Style:styleName];
  }
  else if ([view isKindOfClass:NSClassFromString(@"UITextView")]) {
    [self applyStyleForTextView:(UITextView *)view Style:styleName];
  }
  else if ([view isKindOfClass:NSClassFromString(@"UITableViewCell")]) {
    [self applyStyleForCell:(UITableViewCell *)view Style:styleName];
  }
  else if ([view isKindOfClass:NSClassFromString(@"UISwitch")]) {
    [self applyStyleForSwitch:(UISwitch *)view Style:styleName]; 
  }
  else if ([view isKindOfClass:NSClassFromString(@"UITableView")]) {
    [self applyStyleForTable:(UITableView *)view Style:styleName];
  }
  else if ([view isKindOfClass:NSClassFromString(@"UILabel")]) {
    [self applyStyleForLabel:(UILabel *)view Style:styleName];
  }
  else if ([view isKindOfClass:NSClassFromString(@"UINavigationBar")] || 
           [view isKindOfClass:NSClassFromString(@"UIToolbar")] ||
           [view isKindOfClass:NSClassFromString(@"UISearchBar")]) {
    [self applyStyleForBar:(UINavigationBar*)view Style:styleName];
  }
  else if([view isKindOfClass:[UISegmentedControl class]]) {
    [self applyStyleForSegmentedControl:(UISegmentedControl*)view Style:styleName];
  }
  else {
    [self applyStyleForView:(UIView *)view Style:styleName];
  }
}

#pragma mark Private declarations

- (void)applyStyleForButton:(UIButton*)button Style:(NSString*)styleName {
  if (button == nil)
    return;
  
  NSDictionary* styles = [contentOfStylesFile objectForKey:styleName];
  
  if(styles == nil)
    return;
  
  button.layer.masksToBounds = YES;
  
  for( NSString* key in [styles allKeys]) {
    if ([key isEqualToString:@"CornerRadius"]) {
      [button.layer setCornerRadius:[(NSNumber *)[styles objectForKey:key] floatValue]];
    }
    else if ([key isEqualToString:@"TitleColor_Normal"]) {
      [button setTitleColor:[self colorWithString:(NSString*)[styles objectForKey:key]] 
                   forState:UIControlStateNormal];
    }
    else if ([key isEqualToString:@"TitleColor_Highlighted"]) {
      [button setTitleColor:[self colorWithString:(NSString*)[styles objectForKey:key]] 
                   forState:UIControlStateHighlighted];
    }
    else if ([key isEqualToString:@"BackgroundColor"]) {
      [button.titleLabel setBackgroundColor:[UIColor clearColor]];
      button.backgroundColor = [self colorWithString:(NSString*)[styles objectForKey:key]];
    }
    else if ([key isEqualToString:@"BackgroundImage_Normal"]) {
      int capWidth = [[styles objectForKey:@"CapWidth"] intValue];
      int capHeight = [[styles objectForKey:@"CapHeight"] intValue];
      UIImage* normalImage = [[UIImage imageNamed:(NSString*)[styles objectForKey:key]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:capHeight];
      [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    } 
    else if ([key isEqualToString:@"BackgroundImage_Highlited"]) {
      int capWidth = [[styles objectForKey:@"CapWidth"] intValue];
      int capHeight = [[styles objectForKey:@"CapHeight"] intValue];
      UIImage* normalImage = [[UIImage imageNamed:(NSString*)[styles objectForKey:key]] stretchableImageWithLeftCapWidth:capWidth topCapHeight:capHeight];
      [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    }
    else if([key isEqualToString:@"BorderColor"])
    {
      button.layer.borderColor = [self colorWithString:(NSString*)[styles objectForKey:key]].CGColor;
    }
    else if([key isEqualToString:@"BorderWidth"])
    {
      button.layer.borderWidth = [(NSNumber*)[styles objectForKey:key] floatValue];
    }
  }
}

- (void)applyStyleForTextField:(UITextField *)textField Style:(NSString *)styleName {
  if (textField == nil) {
    return;
  }
  
  NSDictionary* styles = [contentOfStylesFile objectForKey:styleName];
  if (styles == nil) {
    return;
  }
  
  for (NSString* key in [styles allKeys]) {
    if ([key isEqualToString:@"CornerRadius"]) {
      textField.layer.cornerRadius = [[styles objectForKey:key] intValue];
    }
  }
}

- (void)applyStyleForCell:(UITableViewCell *)cell Style:(NSString *)styleName {
  if (cell == nil) {
    return;
  }
  
  NSDictionary* styles = [contentOfStylesFile objectForKey:styleName];
  if (styles == nil) {
    return;
  }

  for (NSString* key in [styles allKeys]) {
    if ([key isEqualToString:@"ContentViewBackgroundColor"]) {
      cell.contentView.backgroundColor = [self colorWithString:[styles objectForKey:key]];
    } else if ([key isEqualToString:@"BackgroundColor"]) {
      cell.backgroundColor = [self colorWithString:[styles objectForKey:key]];
    } else if ([key isEqualToString:@"BackgroundImage"]) {
      cell.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:[styles objectForKey:key]] stretchableImageWithLeftCapWidth:36 topCapHeight:0]] autorelease];
    } else if ([key isEqualToString:@"SelectedImage"]) {
      cell.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:[styles objectForKey:key]] stretchableImageWithLeftCapWidth:36 topCapHeight:0]] autorelease];
    }
    cell.textLabel.backgroundColor = [UIColor clearColor];
  }
}

- (void)applyStyleForSwitch:(UISwitch*)switchView Style:(NSString*)styleName {
  if (switchView == nil)
    return;  
  switchView.layer.cornerRadius = switchView.bounds.size.height/2;
}

- (void)applyStyleForTable:(UITableView*)table Style:(NSString*)styleName {
  if (table == nil) {
    return;
  }
  
  NSDictionary* styles = [contentOfStylesFile objectForKey:styleName];
  if (styles == nil) {
    return;
  }
  
  for (NSString* key in [styles allKeys]) {
    if ([key isEqualToString:@"SeparatorColor"]) {
      table.separatorColor = [self colorWithString:[styles objectForKey:key]];
    }
  }
}

- (void)applyStyleForLabel:(UILabel*)label Style:(NSString*)styleName  {
  if (label == nil)
    return;
  
  NSDictionary* styles = [contentOfStylesFile objectForKey:styleName];
  if(styles == nil)
    return;
  
  for(NSString*key in [styles allKeys]) {
    if ([key isEqualToString:@"FontSize"]) {
        label.font =  [label.font fontWithSize:[(NSNumber*)[styles objectForKey:key] floatValue]];
    }
    else if ([key isEqualToString:@"BackgroundColor"]) {
      label.backgroundColor = [self colorWithString:(NSString*)[styles objectForKey:key]];
    }
  }
}

- (void)applyStyleForView:(UIView*)view Style:(NSString*)styleName {
  if (view == nil)
    return;
  
  NSDictionary* styles = [contentOfStylesFile objectForKey:styleName];
  if(styles == nil)
    return;
  
  for(NSString*key in [styles allKeys]) {
    if ([key isEqualToString:@"BackgroundColor"]) {
      [view setBackgroundColor:[self colorWithString:(NSString*)[styles objectForKey:key] ]];
    }
  }
}

- (void)applyStyleForBar:(UINavigationBar*)bar Style:(NSString*)styleName {
  if (bar == nil)
    return;
	
  NSDictionary* styles = [contentOfStylesFile objectForKey:styleName];
  if(styles == nil)
    return;
  
  for(NSString*key in [styles allKeys]) {
    if ([key isEqualToString:@"TintColor"]) {
      [bar setTintColor:[self colorWithString:(NSString*)[styles objectForKey:key]]];
    } else if ([key isEqualToString:@"BackgroundImage"]) {
    
      
      UIImage* bgImage = [UIImage imageNamed:[styles objectForKey:key]];
      
      if([bar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        //iOS 5 new UINavigationBar custom background
        [bar setBackgroundImage:bgImage forBarMetrics: UIBarMetricsDefault];
      } 
      else
      {
        int capWidth = [[styles objectForKey:@"CapWidth"] intValue];
        int capHeight = [[styles objectForKey:@"CapHeight"] intValue];
        
//        NSLog(@"capW %d capH %d",capWidth,capHeight);
        int height;
        if ([Utils isDeviceiPad])
          height = 44;
        else 
          height = 32;
        
        UIImageView* bgView = (UIImageView*)[bar viewWithTag:NAVBAR_BG_IMAGEVIEW_TAG];
        if (bgView == nil) {

          bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bar.bounds.size.width, height)];
          [bar addSubview:bgView];
          bgView.tag = NAVBAR_BG_IMAGEVIEW_TAG;
          [bar sendSubviewToBack:bgView];
        }
        
        bgView.image = bgImage;
        if (capWidth > 0 || capHeight > 0)
        {
          bgView.image = [bgView.image stretchableImageWithLeftCapWidth:capWidth topCapHeight:capHeight];
        }
        
        bar.backgroundColor = [UIColor clearColor];
        
        //[bar insertSubview:bgView atIndex:0];
      }
    }
  }
	
//	bar.translucent = YES;
//	
//	bar.backgroundColor = [UIColor clearColor];
	
//	bar.barTintColor = [UIColor clearColor];
}

- (void)applyStyleForSegmentedControl:(UISegmentedControl*)view Style:(NSString*)styleName {
  if (view == nil)
    return;
  
  NSDictionary* styles = [contentOfStylesFile objectForKey:styleName];
  if(styles == nil)
    return;
  
  for(NSString*key in [styles allKeys]) {
    if ([key isEqualToString:@"TintColor"]) {
      view.tintColor = [self colorWithString:(NSString*)[styles objectForKey:key]];
    }
  }
}

- (void)applyStyleForTextView:(UITextView*)textView Style:(NSString*)styleName {
  if (textView == nil)
    return;
  
  NSDictionary* styles = [contentOfStylesFile objectForKey:styleName];
  if(styles == nil)
    return;
  
  for(NSString*key in [styles allKeys]) {
    if([key isEqualToString:@"BorderColor"]) {
      textView.layer.borderColor = [self colorWithString:(NSString*)[styles objectForKey:key]].CGColor;
    } else if([key isEqualToString:@"BorderWidth"]) {
      textView.layer.borderWidth = [(NSNumber*)[styles objectForKey:key] floatValue];
    } else if ([key isEqualToString:@"CornerRadius"]) {
      [textView.layer setCornerRadius:[(NSNumber*)[styles objectForKey:key] floatValue]];
    }
  }
}
- (UIColor *)colorWithString:(NSString *)stringToConvert {  
  NSString *cString = [stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  
  
  // Proper color strings are denoted with braces  
  if (![cString hasPrefix:@"{"]) return [UIColor blackColor];  
  if (![cString hasSuffix:@"}"]) return [UIColor blackColor];  
  
  // Remove braces      
  cString = [cString substringFromIndex:1];  
  cString = [cString substringToIndex:([cString length] - 1)];  
 // CFShow(cString);
  
  // Separate into components by removing commas and spaces  
  NSArray *components = [cString componentsSeparatedByString:@","];  
  if ([components count] != 4) return [UIColor blackColor];  
  
  // Create the color  
  return [UIColor colorWithRed:[[components objectAtIndex:0] floatValue]/(float)255  
                         green:[[components objectAtIndex:1] floatValue]/(float)255   
                          blue:[[components objectAtIndex:2] floatValue]/(float)255  
                         alpha:[[components objectAtIndex:3] floatValue]/(float)255];  
}  

@end
