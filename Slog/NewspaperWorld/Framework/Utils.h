//
//  Utils.h
//  Slog
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (BOOL)isiOS7;

+ (BOOL)isPortrait;

+ (BOOL)isDeviceiPad;

+ (UIBarButtonItem *)createSquareNavigationBarButtonWithImage:(UIImage *)icon target:(id)target action:(SEL)action;

+ (UIBarButtonItem *)createSquareToolBarButtonWithImage:(UIImage *)icon target:(id)target action:(SEL)action;


+ (UIBarButtonItem *)barButtonWithImage:(UIImage *)icon 
                             background:(UIImage *)background
                                   size:(CGSize)size 
                                 target:(id)target 
                                 action:(SEL)action;

+ (UILabel *)createTitleLabelWithText:(NSString *)text;

+ (void)showAlertWithTitle:(NSString *)title text:(NSString *)text delegate:(id<UIAlertViewDelegate>)delegate;

+ (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle;

+ (NSString *)documentsDirectoryPath;

+ (NSString*)tempDirectoryPath;

+ (NSString*)cacheDirectoryPath;

+ (float)getFreeSpace;

//Security routines

+ (NSString *)md5WithString:(NSString *)strData;

+ (BOOL)fileExistsAtPath:(NSString*)path;

+ (BOOL)createDirectoryAtPath:(NSString*)path Forced:(BOOL)forced;

+ (UIImage*)imageWithName:(NSString*)name 
              scaledToSize:(CGSize)newSize;

+ (UIImage*)image:(UIImage*)img
             scaledToSize:(CGSize)newSize;

+ (NSString*)uniqueString;

+ (BOOL)isiOS5;

+ (float)verIos;

+ (NSString*)formatDistance:(double)distance;

+ (NSString*)extractFileNameFromPath:(NSString*)path;

+ (NSData*)removeBadSymbolsFromXMLData:(NSData*)xml;

+ (UIView*)loadViewOfClass:(Class)class FromNibNamed:(NSString*)nibName;

+ (void)setEmptyFooterToTable:(UITableView*)tableView;

+ (void) addGradient:(UIButton *) _button;

+(UIBarButtonItem*)customNC:(UINavigationBar*)navi andTitle:(NSString*)title withAction:(SEL)action forTarget:(id)target;


@end


@interface UIColor(Utils)

+ (UIColor*)colorWithR:(unsigned char)r G:(unsigned char)g B:(unsigned char)b A:(unsigned char)a;

@end

@interface NSObject(MemoryManagement)

- (void)safeRelease;
@end

@interface NSString (Utils)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

- (NSString*)stringByDeletingLastWord:(NSString**)lastWord;

- (NSData*) hexToBytes;

- (NSMutableArray*)divideByWhitespacesAnNewlinesWithBlock:(void (^)(NSString *wordWithDelimiter, BOOL *stop))block;

@end

@interface NSData (Crypto)

- (NSData *)AES128DecryptWithKey:(NSData *)key;

- (NSData *)AES128EncryptWithKey:(NSData *)key;
@end

