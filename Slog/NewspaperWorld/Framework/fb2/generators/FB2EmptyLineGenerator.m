//
//  FB2EmptyLineGenerator.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 09.04.13.
//
//

#import "FB2EmptyLineGenerator.h"
#import "FB2PageGeneratorContext.h"
#import "FB2TextStyle.h"

@implementation FB2EmptyLineGenerator

- (void)generatePagesForItem:(FB2Item *)item withContext:(FB2PageGeneratorContext *)context parentStyle:(FB2TextStyle *)parentStyle
{
    FB2TextStyle* style = parentStyle;
    if (!style)
        style = [[[FB2TextStyle alloc] init] autorelease];
    
    [context nextStringWithLineHeight:style.textFont.lineHeight];
}
@end
