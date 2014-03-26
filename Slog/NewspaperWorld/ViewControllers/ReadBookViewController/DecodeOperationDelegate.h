//
//  DecodeOperationDelegate.h
//  NewspaperWorld
//

#import <Foundation/Foundation.h>

@protocol DecodeOperationDelegate<NSObject>

- (void)decodeOperationFinishedWithData:(NSData*)decodedData;

- (void)decodeOperationFailed;

@end
