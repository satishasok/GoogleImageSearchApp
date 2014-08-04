//
//  GImgSearchImageCachingService.m
//  GoogleImageSearchApp
//
//  Created by Satish Asok on 8/3/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import "GImgSearchImageCachingService.h"

@interface GImgSearchImageCachingService ()

@property (strong, nonatomic) NSCache *imageCache;

@end

@implementation GImgSearchImageCachingService

// singleton instance of the GImgSearchImageCachingService & thread safe.
+ (GImgSearchImageCachingService *)sharedInstance
{
	static GImgSearchImageCachingService *_sharedInstance = nil;
	
	static dispatch_once_t predicate;
	dispatch_once(&predicate, ^{
		_sharedInstance = [[GImgSearchImageCachingService alloc] init];
	});
	
	return _sharedInstance;
}

// lazy loading of the cache.
- (NSCache *)imageCache
{
    if (!_imageCache) {
        _imageCache = [[NSCache alloc] init];
    }
    
    return _imageCache;
}

- (void)addImage:(UIImage *)image forKey:(id)key
{
    if (key && image && [image isKindOfClass:[UIImage class]]) {
        [self.imageCache setObject:image forKey:key];
    }
}

- (UIImage *)imageForKey:(id)key
{
    UIImage *image = nil;
    if (key) {
        id object = [self.imageCache objectForKey:key];
        if (object && [object isKindOfClass:[UIImage class]]) {
            image = (UIImage *)object;
        }
    }
    return  image;
}

- (void) clearCache
{
    [self.imageCache removeAllObjects];
}

@end
