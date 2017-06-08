//
//  NSData.m
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "NSData+zip.h"
#import "zlib.h"

@implementation NSData(zip)
-(NSData*)zipData
{
    // this data is empty
    if (0 == [self length])
    {
        return NULL;
    }
    
    // init stream
    z_stream stream;
    memset(&stream, 0, sizeof(stream));
//    stream.next_in = (Bytef*)[self bytes];
//    stream.avail_in = [self length];
//    stream.total_in = [self length];
//    stream.total_out = 0;
//    stream.zalloc = NULL;
//    stream.zfree = NULL;
    
    // init buffer
    NSUInteger half_length = [self length]/2 + 1;
    NSMutableData* zipData = [NSMutableData dataWithLength:[self length]];
    if (Z_OK == deflateInit(&stream, Z_BEST_COMPRESSION))
    {
        stream.next_in = (Bytef*)[self bytes];
        stream.next_out = [zipData mutableBytes];
        stream.avail_in = (uInt)[self length];
        Boolean done = NO;
        while (!done) 
        {
            // increase buffer
            if (stream.total_out >= [zipData length])
            {
                [zipData increaseLengthBy:half_length];
            }
            
//            stream.next_in = (Bytef*)[self bytes];
//            stream.next_out = [zipData mutableBytes] + stream.total_out;
//            stream.avail_in = [self length];
            stream.avail_out = (uInt)([zipData length] - (uLong)stream.total_out);
            
            int status = deflate(&stream, (0==stream.avail_in) ? Z_FINISH : Z_SYNC_FLUSH);
            if (Z_STREAM_END == status)
            {
                done = YES;
            }
            else if (Z_OK != status)
            {
                break;
            }
        }
        
        if (done && Z_OK == deflateEnd(&stream))
        {
            [zipData setLength:stream.total_out];
            return [NSData dataWithData:zipData];
        }
    }
    
    return NULL;
}

-(NSData*)unzipData
{
    // this data is empty
    if (0 == [self length])
    {
        return NULL;
    }
    
    // init stream
    z_stream stream;
    stream.next_in = (Bytef*)[self bytes];
    stream.avail_in = (uInt)[self length];
    stream.total_out = 0;
    stream.zalloc = NULL;
    stream.zfree = NULL;
    
    // init buffer
    NSUInteger half_length = [self length]/2 + 1;
    NSMutableData* unzipData = [NSMutableData dataWithLength:[self length] + half_length];
    if (Z_OK == inflateInit2(&stream, 15+32))
    {
        Boolean done = NO;
        while (!done) 
        {
            // increase buffer
            if (stream.total_out >= [unzipData length])
            {
                [unzipData increaseLengthBy:half_length];
            }
            
            stream.next_out = [unzipData mutableBytes] + stream.total_out;
            stream.avail_out = (uInt)([unzipData length] - stream.total_out);
            
            int status = inflate(&stream, Z_SYNC_FLUSH);
            if (Z_STREAM_END == status)
            {
                done = YES;
            }
            else if (Z_OK != status)
            {
                break;
            }
        }
        
        if (done && Z_OK == inflateEnd(&stream))
        {
            [unzipData setLength:stream.total_out];
            return [NSData dataWithData:unzipData];
        }
    }
    
    return NULL;
}
@end
