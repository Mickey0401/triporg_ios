//
//  WebImageOperations.h
//  Triporg
//
//  Created by tiyasi on 10/09/13.
//
//

#import <Foundation/Foundation.h>

@interface WebImageOperations : NSObject {
}

/** This takes in a URL string and returns imagedata processed on a background thread */
+ (void)processImageDataWithURLString:(NSString *)urlString andBlock:(void (^)(NSData *imageData))processImage;

@end
