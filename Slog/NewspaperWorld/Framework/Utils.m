//
//  Utils.m
//  Slog
//


#import "Utils.h"
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

#import "ResourcesNames.h"

@implementation Utils

+ (BOOL)isPortrait
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        return YES;
    }
    return NO;
}

+(void) addGradient:(UIButton *) _button
{
    
    // Add Border
    CALayer *layer = _button.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 0.5f;
    layer.borderColor = [UIColor blackColor].CGColor;
    
    // Add Shine
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.frame = layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:0.6f alpha:0.4f].CGColor,
                         (id)[UIColor colorWithWhite:0.6f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.45f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.2f alpha:0.2f].CGColor,
                         (id)[UIColor colorWithWhite:0.8f alpha:0.4f].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.5f],
                            [NSNumber numberWithFloat:0.8f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [layer addSublayer:shineLayer];
}

+(UIBarButtonItem*)customNC:(UINavigationBar*)naviBar andTitle:(NSString*)title withAction:(SEL)action forTarget:(id)target
{
    UIImageView *imageView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav_bg"]] autorelease];
    imageView.tag = 1001;
    naviBar.backgroundColor = [UIColor colorWithPatternImage:imageView.image];
    
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(5, 5, 80, 30);
    
    [customButton setTitle:NSLocalizedString(title, @"") forState:UIControlStateNormal];
    customButton.backgroundColor = [UIColor colorWithRed:180.f/255.f green:6.f/255.f blue:15.f/255.f alpha:1];
    [customButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [Utils addGradient:customButton];
    customButton.layer.cornerRadius = 5.0f;
    customButton.layer.borderColor = [UIColor blackColor].CGColor;
    customButton.layer.borderWidth = 0.5f;
    customButton.layer.shadowColor = [UIColor grayColor].CGColor;
    
    UIView *containingView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, customButton.bounds.size.width, customButton.bounds.size.height +1)] autorelease];
    
    [containingView addSubview:customButton];
    
    customButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    UIBarButtonItem* backBarButton = [[[UIBarButtonItem alloc]initWithCustomView:containingView] autorelease];
    //backBarButton.action = @selector(backPressed);
    
    backBarButton.tag = 2001;
    
    return backBarButton;
}


+ (BOOL)createDirectoryAtPath:(NSString*)path Forced:(BOOL)forced 
{
  NSFileManager* fm = [NSFileManager defaultManager];
  NSError* error = nil;
  return [fm createDirectoryAtPath:path withIntermediateDirectories:forced attributes:nil error:&error];  
}
+ (BOOL)isDeviceiPad {
  return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (UIBarButtonItem *)createSquareNavigationBarButtonWithImage:(UIImage *)icon target:(id)target action:(SEL)action {
   UIImage* bgImage = [UIImage imageNamed:BG_SQUARE_BUTTON_WO_FRAME];  
  
  int navigationBarButtonSide;
  if ([Utils isDeviceiPad]) {
    navigationBarButtonSide = 38;
  } else {
    navigationBarButtonSide = 28;
  }
  UIBarButtonItem* button = [Utils barButtonWithImage:icon 
                                                background:bgImage 
                                                      size:CGSizeMake(navigationBarButtonSide, navigationBarButtonSide) 
                                                    target:target
                                                    action:action];
  ((UIButton *)button.customView).layer.borderWidth = 0;
  ((UIButton *)button.customView).imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
  return button;
}

+ (float)getFreeSpace
{
    float freeSpace = 0.0f;  
    NSError *error = nil;  	
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[Utils cacheDirectoryPath] error: &error];  
    
    if (dictionary) {  
        NSNumber *fileSystemFreeSizeInBytes = [dictionary objectForKey: NSFileSystemFreeSize];  
        freeSpace = [fileSystemFreeSizeInBytes floatValue];
    }
    
    return freeSpace;
}

+ (UIBarButtonItem *)createSquareToolBarButtonWithImage:(UIImage *)icon target:(id)target action:(SEL)action {
   UIImage* bgImage = [UIImage imageNamed:BG_SQUARE_BUTTON_W_FRAME];  
  
  const int navigationBarButtonSide = 28; 
  UIBarButtonItem* button = [Utils barButtonWithImage:icon 
                                                background:bgImage 
                                                      size:CGSizeMake(navigationBarButtonSide, navigationBarButtonSide) 
                                                    target:target
                                                    action:action];
  ((UIButton *)button.customView).imageEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
  return button;
}

+ (UIBarButtonItem *)barButtonWithImage:(UIImage *)icon background:(UIImage *)background size:(CGSize)size target:(id)target action:(SEL)action {
  UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
  
  [button setBackgroundImage:background forState:UIControlStateNormal];
  [button setImage:icon forState:UIControlStateNormal];
  [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  
  button.layer.cornerRadius = 8.0f;
  button.layer.masksToBounds = YES;
  button.layer.borderWidth = 2.5f;
  button.layer.borderColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0f].CGColor;
  
  button.frame = CGRectMake(0, 0, size.width, size.height);
  
  return [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}

+ (UILabel *)createTitleLabelWithText:(NSString *)text {
  UILabel* titleLabel = [[[UILabel alloc] init] autorelease];
  titleLabel.backgroundColor = [UIColor clearColor];
  titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
  titleLabel.shadowColor = [UIColor colorWithWhite:0.5 alpha:1];
  titleLabel.textAlignment = UITextAlignmentCenter;
  titleLabel.textColor = [UIColor blackColor];
  titleLabel.text = text;
  const int labelWidth = [Utils isDeviceiPad] ? 540 : 340;
  titleLabel.frame = CGRectMake(0, 0, labelWidth, 40);
  return titleLabel;
}

+ (void)showAlertWithTitle:(NSString *)title text:(NSString *)text delegate:(id<UIAlertViewDelegate>)delegate {
  UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:title message:text delegate:delegate cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
  [alertView show];
}

+ (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle
{
  CGFloat angleInRadians = angle * (M_PI / 180);
  CGFloat width = CGImageGetWidth(imgRef);
  CGFloat height = CGImageGetHeight(imgRef);
  
  CGRect imgRect = CGRectMake(0, 0, width, height);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  CGContextRef bmContext = CGBitmapContextCreate(NULL, imgRect.size.width, imgRect.size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
  CGContextSetAllowsAntialiasing(bmContext, YES);
  CGContextSetShouldAntialias(bmContext, YES);
  CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
  CGColorSpaceRelease(colorSpace);
  CGContextTranslateCTM(bmContext, +(imgRect.size.width/2), +(imgRect.size.height/2));
  CGContextRotateCTM(bmContext, angleInRadians);
  CGContextTranslateCTM(bmContext, -(imgRect.size.width/2), -(imgRect.size.height/2));
  CGContextDrawImage(bmContext, CGRectMake(0, 0, imgRect.size.width, imgRect.size.height), imgRef);
  
  CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
  CFRelease(bmContext);
  [(id)rotatedImage autorelease];
  
  return rotatedImage;
}

+ (NSString *)documentsDirectoryPath 
{
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString*)tempDirectoryPath
{ 
  return NSTemporaryDirectory();
}

+ (NSString*)cacheDirectoryPath
{
  return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)md5WithString:(NSString *)strData
{
  const char *cStr = [strData UTF8String];
  unsigned char result[16];
  CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
  return [NSString stringWithFormat:
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3], 
          result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11],
          result[12], result[13], result[14], result[15]]; 
}

+ (BOOL)fileExistsAtPath:(NSString*)path {
  if (!path)
    return NO;
  return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (UIImage*)imageWithName:(NSString*)name 
              scaledToSize:(CGSize)newSize
{
  UIImage* image = [UIImage imageNamed:name];
  return [Utils image:image scaledToSize:newSize];
}

+ (UIImage*)image:(UIImage*)image
     scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (BOOL)isiOS5 {
  NSString *ver = [[UIDevice currentDevice] systemVersion];
  float ver_float = [ver floatValue];
  
  if (ver_float < 5.0) 
    return NO;
  
  return YES;
}

+ (BOOL)isiOS7 {
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    
    if (ver_float < 7.0)
        return NO;
    
    return YES;
}

+ (float)verIos
{
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    
    float ver_float = [ver floatValue];
    
    return ver_float;
}

+ (NSString*)formatDistance:(double)distance
{
  NSString* result = nil;
  
  NSString *suffix = NSLocalizedString(@"IDS_M", nil);
  if(distance > 1000.0) {
    
    distance = distance/1000.0;
    suffix = NSLocalizedString(@"IDS_KM", nil);
    result = [NSString stringWithFormat:@"%.1f %@", distance, suffix];  
    
  }
  else {
    result = [NSString stringWithFormat:@"%d %@", (int)distance, suffix];  
    
  }
  
  return result;
}

+ (NSString*)extractFileNameFromPath:(NSString*)path
{
  NSArray* components = [path pathComponents];
  if ([components count] > 0)
  {
    return [components objectAtIndex:[components count] - 1];
  }
  return nil;
}

+ (NSData*)removeBadSymbolsFromXMLData:(NSData*)xmlData
{
  if (!xmlData)
    return nil;
  
  NSString* xml = [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] autorelease];
  xml = [xml stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
  xml = [xml stringByReplacingOccurrencesOfString:@"\n" withString:@""];
 return [xml dataUsingEncoding:NSUTF8StringEncoding];
}

+ (UIView*)loadViewOfClass:(Class)class FromNibNamed:(NSString*)nibName
{
    UIView* result = nil;    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    for (UIView* view in views)
    {
        if ([view isKindOfClass:class])
        {
            result = view;
            break;
        }
    }
    return result;
}
+ (void)setEmptyFooterToTable:(UITableView*)tableView
{
    UIView* zeroFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0)];
    tableView.tableFooterView = zeroFooter;
    [zeroFooter release];
}

+ (NSString*)uniqueString
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@", (NSString *)uuidString];
    CFRelease(uuidString);
    return  uniqueFileName;
}

@end


@implementation UIColor(Utils)

+ (UIColor*)colorWithR:(unsigned char)r G:(unsigned char)g B:(unsigned char)b A:(unsigned char)a
{
    return [UIColor colorWithRed:(double)r/255.0 green:(double)g/255.0 blue:(double)b/255.0 alpha:(double)a/255.0];
}
@end

@implementation NSObject(MemoryManagement)

- (void)safeRelease
{
    [self release];
    *(&self) = nil;
}

@end

@implementation NSData(Crypto)

- (NSData *)AES128DecryptWithKey:(NSData *)key
{
    NSUInteger dataLength = [self length];
       
   
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
        
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode,
                                              key.bytes, kCCKeySizeAES128,
                                              NULL /* initialization vector (optional) */,
                                              [self bytes], dataLength, /* input */
                                              buffer, bufferSize, /* output */
                                              &numBytesDecrypted);
        
    if (cryptStatus == kCCSuccess) {
            //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
        
    free(buffer); //free the buffer;
    return nil;
}

- (NSData *)AES128EncryptWithKey:(NSData *)key
{
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, 0,
                                          key.bytes, kCCKeySizeAES128,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess) {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return nil;

}
@end



@implementation NSString (Utils)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    NSString* temp = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                         (CFStringRef)self,
                                                                         NULL,
                                                                         (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                         CFStringConvertNSStringEncodingToEncoding(encoding));
    
    [temp autorelease];
	return temp;
}

- (NSData*) hexToBytes
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= self.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [self substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

- (BOOL)isWordDelimiter:(unichar)ch
{
    return (ch == ' ' || ch =='\n');
}

- (NSString*)stringByDeletingLastWord:(NSString **)lastWord
{    
    if (!lastWord)
        return nil;
    
    NSString* last = @"";
    
    NSString* result = [NSString stringWithString:self];
        
    BOOL waitBreak = NO;
    int index = (int)[self length]-1;
    for (; index >= 0; index--)
    {
        unichar ch = [self characterAtIndex:index];
        last = [[NSString stringWithFormat:@"%C",ch] stringByAppendingString:last];
        if (!waitBreak && ![self isWordDelimiter:ch])
        {
            waitBreak = YES;
        }       
        if (waitBreak && [self isWordDelimiter:ch])
            break;
    }
    if (index != -1)
        result = [self substringToIndex:index];
    
    *lastWord = last;
    return result;
}

- (NSMutableArray*)divideByWhitespacesAnNewlinesWithBlock:(void (^)(NSString *wordWithDelimiter, BOOL *stop))block
{
    NSMutableArray* result = [NSMutableArray array];
    NSCharacterSet* divideSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSMutableString* word = [NSMutableString string];
    
    BOOL stop = false;
    BOOL frontBlanks = YES;
    for(int i = 0; i < self.length; i++)
    {
        unichar character = [self characterAtIndex:i];
        if (([divideSet characterIsMember:character] && !frontBlanks) || i == self.length - 1 )
        {
            [word appendFormat:@"%C", character];
            if (block)
                block(word, &stop);
            
            if (stop)
                break;
            [result addObject:[NSString stringWithString:word]];
            [word setString:@""];
        }
        else
        {
            frontBlanks = NO;
            [word appendFormat:@"%C", character];
        }
    }
    return result;
}
@end