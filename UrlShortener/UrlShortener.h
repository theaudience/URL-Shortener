//
/*
 //  UrlShortenerLoader.h
 //  UrlShortener
 Copyright (c) 2011 Jochen Herrmann
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 */

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(NSString *shortUrl);
typedef void (^ErrorBlock)(NSError *error);

@protocol UrlShortenerDelegate <NSObject>

@optional
- (void)urlShortenerSucceededWithShortUrl:(NSString *)shortUrl;
- (void)urlShortenerFailedWithError:(NSError *)error;

@end

typedef enum {
    UrlShortenerServiceRedirect,
    UrlShortenerServiceBitly,
    UrlShortenerServiceJmp,
    UrlShortenerServiceGoogle,
    UrlShortenerServiceIsgd
} UrlShortenerService;

@interface UrlShortener : NSObject {
    NSURLConnection *_connection;
    NSMutableData *_data;
    __weak id<UrlShortenerDelegate> delegate;
    UrlShortenerService _service;
}

@property (nonatomic, weak) id<UrlShortenerDelegate> delegate;

- (id)initWithDelegate:(id)del;

- (void)shortenUrl:(NSString *)longUrl withService:(UrlShortenerService)service;

- (void)shortenUrl:(NSString *)longUrl withService:(UrlShortenerService)service completion:(CompletionBlock)completionBlock error:(ErrorBlock)errorBlock;

@end
