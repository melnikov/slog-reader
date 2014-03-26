//
//  FB2PageImageItem.h
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 22.03.13.
//
//

#import "FB2PageDataItem.h"

@interface FB2PageImageItem : FB2PageDataItem

- (id)initWithImage:(UIImage*)aImage
          frameRect:(CGRect)aFrame
          fb2ItemID:(int)ID
      originalImage:(UIImage*)aOriginalImage;

+ (FB2PageImageItem*)itemWithImage:(UIImage*)aImage
                         frameRect:(CGRect)frame
                         fb2ItemID:(int)ID
                     originalImage:(UIImage*)aOriginalImage;

@property (nonatomic, readonly) BOOL canZoom;

@property (nonatomic, readonly) UIImage* originalImage;

@end
