//
//  FB2PlainTextGenerator.h
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 08.04.13.
//
//

#import <Foundation/Foundation.h>
#import "FB2PageGeneratorContext.h"
#import "FB2TextStyle.h"

@interface FB2PlainTextGenerator : NSObject 

- (void)generatePagesForTextBlock:(NSString*)currentTextBlock
                                fb2ItemID:(int)ID
                                textStyle:(FB2TextStyle*)style
                                  context:(FB2PageGeneratorContext*)context;
@end
