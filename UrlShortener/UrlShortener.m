/*
//  UrlShortenerLoader.m
//  UrlShortener
 Copyright (c) 2011 Jochen Herrmann
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/
#import "UrlShortener.h"

#define BITLY_LOGIN     @"BITLY_LOGIN"
#define BITLY_APIKEY    @"BITLY_APIKEY"
#define APP_NAME        @"APP_NAME"

#define CLIGS_URL       @"http://cli.gs/api/v1/cligs/create?url=%@&appid=%@"
#define REDIRECT_URL    @"http://redir.ec/_api/rest/redirec/create?url=%@&appid=%@"
#define BITLY_URL       @"http://api.bit.ly/v3/shorten?format=txt&longurl=%@&apikey=%@&login=%@"
#define JMP_URL         @"http://api.bit.ly/v3/shorten?format=txt&longurl=%@&apikey=%@&login=%@&domain=j.mp"
#define ISGD_URL        @"http://is.gd/create.php?format=simple&url=%@"

static CompletionBlock _completionBlock;
static ErrorBlock _errorBlock;

@interface UrlShortener ()
- (NSString *)encodeURL:(NSString *)url;
@end

@implementation UrlShortener

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] init];
    }
    return self;
}

- (id)initWithDelegate:(id)del {
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] init];
        delegate = del;
    }
    return self;
}

- (NSString *)encodeURL:(NSString *)url {
    NSString * encoded = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                NULL,
                                                                                (__bridge CFStringRef)url,
                                                                                NULL,
                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                kCFStringEncodingUTF8);
    return encoded;
}

- (void)shortenUrl:(NSString *)longUrl withService:(UrlShortenerService)service {
    if (_connection == nil)
    {
    	NSString *encodedUrl = [self encodeURL:longUrl];
        _service = service;
        NSMutableURLRequest *request;
        if (service == UrlShortenerServiceRedirect) {
            NSString *endPoint = [NSString stringWithFormat:REDIRECT_URL, encodedUrl, APP_NAME];
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:endPoint]];
        }
        else if (service == UrlShortenerServiceGoogle) {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.googleapis.com/urlshortener/v1/url"]
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:60.0];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[[NSString stringWithFormat:@"{\"longUrl\": \"%@\"}", longUrl] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else if (service == UrlShortenerServiceIsgd) {
            NSString *endPoint = [NSString stringWithFormat:ISGD_URL, encodedUrl];
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:endPoint]];
        }
        else if (service == UrlShortenerServiceJmp) {
            NSString *endPoint = [NSString stringWithFormat:JMP_URL, encodedUrl, BITLY_APIKEY, BITLY_LOGIN];
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:endPoint]];
        }
        else {
            NSString *endPoint = [NSString stringWithFormat:BITLY_URL, encodedUrl, BITLY_APIKEY, BITLY_LOGIN];
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:endPoint]];
        }
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

- (void)shortenUrl:(NSString *)longUrl withService:(UrlShortenerService)service completion:(CompletionBlock)completionBlock error:(ErrorBlock)errorBlock {
    _completionBlock = [completionBlock copy];
    _errorBlock = [errorBlock copy];
    [self shortenUrl:longUrl withService:service];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *shortUrl = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    if (_service == UrlShortenerServiceGoogle) {
        NSArray *components = [shortUrl componentsSeparatedByString:@"\""];
        shortUrl = [components objectAtIndex:7];
    }
    if (_completionBlock) {
        _completionBlock(shortUrl);
        _completionBlock = nil;
        _errorBlock = nil;
        return;
    }
    if (delegate != nil && [delegate respondsToSelector:@selector(urlShortenerSucceededWithShortUrl:)]) {
        [delegate urlShortenerSucceededWithShortUrl:shortUrl];
    }
    _connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_errorBlock) {
        _errorBlock(error);
        _completionBlock = nil;
        _errorBlock = nil;
        return;
    }
    if (delegate != nil && [delegate respondsToSelector:@selector(urlShortenerFailedWithError:)]) {
        [delegate urlShortenerFailedWithError:error];
    }
    _connection = nil;
}
@end
