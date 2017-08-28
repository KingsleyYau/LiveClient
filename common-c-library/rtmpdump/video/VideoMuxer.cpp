//
//  VideoMuxer.cpp
//  RtmpClient
//
//  Created by Max on 2017/8/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoMuxer.h"

#include <common/CommonFunc.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <arpa/inet.h>

namespace coollive {
Slice::Slice() {
    mpSliceData = NULL;
    mSliceSize = 0;
}

Slice::~Slice() {
    
}
    
bool Slice::Parse(const char *sliceData, int sliceDataSize) {
    bool bFlag = true;
    
    mpSliceData = sliceData;
    mSliceSize = sliceDataSize;
    
    return bFlag;
}

const char* Slice::GetSlice() {
    return mpSliceData;
}
    
int Slice::GetSliceSize() {
    return mSliceSize;
}
    
bool Slice::IsFirstSlice() {
    // 这里只做0阶的简单判断, k阶的需要哥伦布编码
    return (mpSliceData[1] >> 7);
}
    
Nalu::Nalu() {
    mpNaluData = NULL;
    mNaluSize = 0;
    mNaluHeaderSize = 0;
    
    mSliceArraySize = 0;
}
    
Nalu::~Nalu() {
    
}
        
bool Nalu::Parse(const char *naluData, int naluDataSize, int naluHeaderSize) {
    bool bFlag = true;
    
    switch (naluHeaderSize) {
        case 1: {
        }break;
        case 2: {
        }break;
        case 4: {
        }break;
        default:{
            bFlag = false;
        }break;
    }
    
    if( bFlag ) {
        mpNaluData = naluData;
        mNaluSize = naluDataSize;
        mNaluHeaderSize = naluHeaderSize;
        
        bFlag = ParseSlices();
    }
    
    return bFlag;
}
    
const char* Nalu::GetNalu() {
    return mpNaluData;
}
    
int Nalu::GetNaluSize() {
    return mNaluSize;
}
    
const char* Nalu::GetNaluBody() {
    return mpNaluData + mNaluHeaderSize;
}
    
int Nalu::GetNaluBodySize() {
    return mNaluSize - mNaluHeaderSize;
}
    
VideoFrameType Nalu::GetNaluType() {
    char nal_unit_type = GetNaluBody()[0] & 0x1f;
    return (VideoFrameType)nal_unit_type;
}
    
void Nalu::GetSlices(Slice** sliceArray, int& sliceArraySize) {
    *sliceArray = mSliceArray;
    sliceArraySize = mSliceArraySize;
}
    
bool Nalu::ParseSlices() {
    bool bFlag = false;
    
    Slice* sliceArray = mSliceArray;
    int sliceArraySize = _countof(mSliceArray);
    if( sliceArray != NULL ) {
        bFlag = true;
        
        int sliceIndex = 0;
        int leftSize = GetNaluBodySize();
        int sliceSize = 0;
        int sliceCodeSize;
        
        const char* sliceStart = GetNaluBody();
        const char* sliceEnd = NULL;
        
        while( leftSize > 0 ) {
            sliceEnd = FindSlice(sliceStart, leftSize, sliceCodeSize);
            if( sliceEnd != NULL ) {
                // 找到Nalu
                sliceSize = (int)(sliceEnd - sliceStart);
                
            } else {
                // 最后一个Nalu
                sliceSize = leftSize;
            }
            
            if( sliceSize > 0 ) {
                if( sliceIndex < sliceArraySize ) {
                    Slice* slice = sliceArray + sliceIndex;
                    sliceIndex++;
                    
                    // 解析单个Nalu
                    bFlag = slice->Parse(sliceStart, sliceSize);
                    if( bFlag ) {
                        leftSize -= (sliceSize + sliceCodeSize);
                        // 切换到下个Nalu
                        sliceStart += (sliceSize + sliceCodeSize);
                    }
                }
                
            } else {
                bFlag = false;
            }
            
            if( !bFlag ) {
                break;
            }
        }
        
        mSliceArraySize = sliceIndex;
    }
    
    return bFlag;
}

const char* Nalu::FindSlice(const char* start, int size, int& sliceSize) {
    static const char sliceStartCode[] = {0x00, 0x00, 0x01};
    
    sliceSize = 0;
    const char* slice = NULL;
    
    for(int i = 0; i < size; i++) {
        if( i + sizeof(sliceStartCode) < size &&
           memcmp(start + i, sliceStartCode, sizeof(sliceStartCode)) == 0 ) {
            sliceSize = sizeof(sliceStartCode);
            slice = start + i;
            break;
        }
    }
    
    return slice;
}

VideoMuxer::VideoMuxer() {
    
};

VideoMuxer::~VideoMuxer() {
    
}
    
bool VideoMuxer::GetNalus(const char* data, int size, int naluHeaderSize, Nalu* naluArray, int& naluArraysize) {
    bool bFlag = false;
    
    if( naluArray != NULL ) {
        bFlag = true;
        
        int naluIndex = 0;
        int leftSize = size;
        int naluSize = 0;
        
        // 每个Nalu头部
        const char* naluHeader = data;
//        const char* naluBody = data + naluHeaderSize;
        
        while( leftSize > 0 ) {
            // 获取每一个NALU大小
            switch (naluHeaderSize) {
                case 1: {
                    naluSize = *(char *)naluHeader;
                }break;
                case 2: {
                    short* pNaluSize = (short *)naluHeader;
                    naluSize = ntohs(*pNaluSize);
                    
                }break;
                case 4: {
                    int* pNaluSize = (int *)naluHeader;
                    naluSize = ntohl(*pNaluSize);
                    
                }break;
                default:{
                    bFlag = false;
                }break;
            }
            
            if( bFlag ) {
                if( naluSize > 0 && (naluSize + naluHeaderSize) <= leftSize ) {
                    if( naluIndex < naluArraysize ) {
                        Nalu* nalu = naluArray + naluIndex;
                        naluIndex++;
                        
                        // 解析单个Nalu
                        bFlag = nalu->Parse(naluHeader, naluSize + naluHeaderSize, naluHeaderSize);
                        if( bFlag ) {
                            leftSize -= (naluSize + naluHeaderSize);
                            
                            // 切换到下个Nalu
                            naluHeader += (naluSize + naluHeaderSize);
                        }
                        
                    } else {
                        bFlag = false;
                    }

                } else {
                    bFlag = false;
                }
            }
            
            if( !bFlag ) {
                break;
            }
        }
        
        naluArraysize = naluIndex;
    }
    
    return bFlag;
}
    
}
