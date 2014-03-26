//
//  FB2PageGenerationOperation.h
//  NewspaperWorld
//
//  Created by Eldar Pikunov on 19.11.12.
//
//

#import <Foundation/Foundation.h>
#import "FB2PagesGeneratorDelegate.h"
#import "FB2PagesGenerator.h"

@interface FB2PageGenerationOperation : NSOperation
{
    FB2PagesGenerator*      _generator;
    
    NSObject<FB2PagesGeneratorDelegate>* _delegate;
}

- (id)initWithGenerator:(FB2PagesGenerator*)generator delegate:(NSObject<FB2PagesGeneratorDelegate>*) delegate;

@end
