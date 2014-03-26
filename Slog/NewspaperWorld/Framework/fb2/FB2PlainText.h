//
//  FBPlainText.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>
#import "FB2TextItem.h"

@interface FB2PlainText : FB2TextItem

+ (FB2TextItem*)itemFromXMLElement:(GDataXMLElement*)element;

@end
