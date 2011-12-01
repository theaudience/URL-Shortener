/*
//  UrlShortenerLoader.m
//  UrlShortener

Copyright (c) 2011, Jochen Herrmann
All rights reserved.
 
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of the <ORGANIZATION> nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

@interface UrlShortener ()
- (NSString *)encodeURL:(NSString *)url;
@end

@implementation UrlShortener

@synthesize delegate;

- (id)initWithDelegate:(id)del {
    self = [super init];
    _data = [[NSMutableData alloc] init];
    delegate = del;
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (delegate != nil && [delegate respondsToSelector:@selector(urlShortenerSucceededWithShortUrl:)]) {
        NSString *shortUrl = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
        if (_service == UrlShortenerServiceGoogle) {
            NSArray *components = [shortUrl componentsSeparatedByString:@"\""];
            [delegate urlShortenerSucceededWithShortUrl:[components objectAtIndex:7]];
            return;
        }
        [delegate urlShortenerSucceededWithShortUrl:shortUrl];
    }
    _connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (delegate != nil && [delegate respondsToSelector:@selector(urlShortenerFailedWithError:)]) {
        [delegate urlShortenerFailedWithError:error];
    }
    _connection = nil;
}
@end
