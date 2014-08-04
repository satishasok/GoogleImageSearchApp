//
//  GImgSearchImageCachingService.h
//  GoogleImageSearchApp
//
//  Created by Satish Asok on 8/3/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GImgSearchImageCachingService : NSObject

// returns singleton instance of the GImgSearchImageCachingService
+ (GImgSearchImageCachingService *)sharedInstance;

// add/retrive image from the cache for a key.
- (void)addImage:(UIImage *)image forKey:(id)key;
- (UIImage *)imageForKey:(id)key;

// clears all images from the cache
- (void) clearCache;

@end
