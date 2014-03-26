//
//  FB2PageImageItem.m
//  NewspaperWorld
//

#import "FB2PageImageItem.h"
#import "NWSettings.h"

@implementation FB2PageImageItem

+ (FB2PageImageItem*)itemWithImage:(UIImage*)aImage
                         frameRect:(CGRect)frame
                         fb2ItemID:(int)ID
                     originalImage:(UIImage*)aOriginalImage
{
    return [[[FB2PageImageItem alloc] initWithImage:aImage
                                        frameRect:frame
                                        fb2ItemID:ID
                                      originalImage:aOriginalImage] autorelease];
}

- (id)initWithImage:(UIImage*)aImage
          frameRect:(CGRect)aFrame
          fb2ItemID:(int)ID
      originalImage:(UIImage*)aOriginalImage
{
    self = [super initWithData:aImage frameRect:aFrame fb2ItemID:ID];
    if (self)
    {
        _originalImage = aOriginalImage;
        [_originalImage retain];
    }
    return self;
}

- (void)dealloc
{
    [_originalImage release];
    [super dealloc];
}

- (BOOL)canZoom
{
    return (_originalImage != nil);
}
@end