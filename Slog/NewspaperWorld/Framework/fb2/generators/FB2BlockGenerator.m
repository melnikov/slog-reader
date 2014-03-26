//
//  FB2BlockGenerator.m
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 08.04.13.
//
//

#import "FB2BlockGenerator.h"
#import "FB2SimpleItemGenerator.h"
#import "FB2TextItem.h"
#import "FB2PageGeneratorContext.h"

@implementation FB2BlockGenerator

- (void)generatePagesForItem:(FB2Item*)item withContext:(FB2PageGeneratorContext*)context parentStyle:(FB2TextStyle*)parentStyle
{
    FB2SimpleItemGenerator* gen = [[FB2SimpleItemGenerator alloc] init];
    [gen generatePagesForItem:item withContext:context parentStyle:parentStyle];    
    [gen release];

    if ([item isKindOfClass:[FB2TextItem class]])
    {
        FB2TextItem* txtItem = (FB2TextItem*)item;

        if (parentStyle.lineHeight > txtItem.textStyle.lineHeight) {
            [context nextStringWithLineHeight:parentStyle.lineHeight];
        } else {
            [context nextStringWithLineHeight:txtItem.textStyle.lineHeight];
        }
    }

}

@end
