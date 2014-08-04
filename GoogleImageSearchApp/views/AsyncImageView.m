//
//  AsyncImageView.m
//  Imaginarium
//
//  Created by Satish Asok on 8/2/14.
//  Copyright (c) 2014 Satish Asok. All rights reserved.
//

#import "AsyncImageView.h"
#import "GImgSearchImageCachingService.h"

@interface AsyncImageView ()

@property (strong, nonatomic) UIActivityIndicatorView *imgDownloadActivityIndicator;
@property (strong, nonatomic) NSURLSessionDownloadTask *urlDownloadTask;
@end

@implementation AsyncImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


-(UIActivityIndicatorView *)imgDownloadActivityIndicator
{
    if (!_imgDownloadActivityIndicator) {
        _imgDownloadActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _imgDownloadActivityIndicator.hidesWhenStopped = YES;
        _imgDownloadActivityIndicator.color = [UIColor blueColor] ;
        _imgDownloadActivityIndicator.frame =
        CGRectMake(self.frame.origin.x+self.frame.size.width/2-_imgDownloadActivityIndicator.frame.size.width/2,
                   self.frame.origin.y+self.frame.size.height/2-_imgDownloadActivityIndicator.frame.size.height/2,
                   _imgDownloadActivityIndicator.frame.size.width, _imgDownloadActivityIndicator.frame.size.height);
        [self addSubview:_imgDownloadActivityIndicator];
    }
    
    return _imgDownloadActivityIndicator;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    
    [self startImageDownload];
    
}

- (void)startImageDownload
{
    [self.imgDownloadActivityIndicator stopAnimating];
    self.image = nil;
    [self.urlDownloadTask cancel];
    
    if (self.imageURL) {
        UIImage * currentImage = [[GImgSearchImageCachingService sharedInstance] imageForKey:self.imageURL];
        if (currentImage) {
            self.image = currentImage;
        } else {
            [self.imgDownloadActivityIndicator startAnimating];
            NSURLRequest *imgURLRequest = [NSURLRequest requestWithURL:self.imageURL];
            NSURLSessionConfiguration *urlConf = [NSURLSessionConfiguration ephemeralSessionConfiguration];
            NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlConf];
            
            self.urlDownloadTask = [urlSession downloadTaskWithRequest:imgURLRequest completionHandler:^(NSURL *localFileURL, NSURLResponse *response, NSError *error) {
                if (!error) {
                    __weak typeof (self) weakSelf = self;
                    UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:localFileURL]];
                    if (downloadedImage) {
                        [[GImgSearchImageCachingService sharedInstance] addImage:downloadedImage forKey:imgURLRequest.URL];
                    }
                    if ([imgURLRequest.URL isEqual:self.imageURL]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.imgDownloadActivityIndicator stopAnimating];
                            weakSelf.image = downloadedImage;
                        });
                    }
                }
            }];
            [self.urlDownloadTask resume];
        }
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
