//
//  FB2Paragraph.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "FB2TextItem.h"

@interface FB2Paragraph : FB2TextItem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;

@end
