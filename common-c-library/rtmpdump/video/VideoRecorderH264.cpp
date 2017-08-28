//
//  VideoRecorderH264.cpp
//  RtmpClient
//
//  Created by Max on 2017/8/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "VideoRecorderH264.h"

#include "VideoFrame.h"

#include <common/CommonFunc.h>
#include <common/KLog.h>

namespace coollive {
VideoRecorderH264::VideoRecorderH264() {
    mFilePath = "";
    mpFile = NULL;
    mNaluHeaderSize = 0;
}
    
VideoRecorderH264::~VideoRecorderH264() {
}

bool VideoRecorderH264::Start(const string& filePath) {
    bool bFlag = false;
    
    mFilePath = filePath;
    
    if( mFilePath.length() > 0 ) {
        remove(mFilePath.c_str());
        mpFile = fopen(mFilePath.c_str(), "w+b");
        if( mpFile ) {
            fseek(mpFile, 0L, SEEK_END);
            bFlag = true;
        }
    }
    
    return bFlag;
}
    
void VideoRecorderH264::Stop() {
    if( mpFile ) {
        fclose(mpFile);
        mpFile = NULL;
    }
}
   
bool VideoRecorderH264::RecordVideoKeyFrame(const char* sps, int sps_size, const char* pps, int pps_size, int nalUnitHeaderLength) {
    bool bFlag = false;
    
    // Write to H264 file
    if( mpFile ) {
        // Write NALU start code
        fwrite(sync_bytes, 1, sizeof(sync_bytes), mpFile);
        
        // Write playload
        fwrite(sps, 1, sps_size, mpFile);
        
        // Write NALU start code
        fwrite(sync_bytes, 1, sizeof(sync_bytes), mpFile);
        
        // Write playload
        fwrite(pps, 1, pps_size, mpFile);
        
        fflush(mpFile);
        
        mNaluHeaderSize = nalUnitHeaderLength;

        bFlag = true;
    }
    
    return bFlag;
}
    
bool VideoRecorderH264::RecordVideoFrame(const char* data, int size) {
    bool bFlag = false;
    
    // Mux
    Nalu naluArray[16];
    int naluArraySize = _countof(naluArray);
    bFlag = mVideoMuxer.GetNalus(data, size, mNaluHeaderSize, naluArray, naluArraySize);
    if( bFlag && naluArraySize > 0 ) {
        bFlag = false;
        
        FileLevelLog("rtmpdump",
                     KLog::LOG_MSG,
                     "VideoRecorderH264::RecordVideoFrame( "
                     "[Got Nalu Array], "
                     "size : %d, "
                     "naluArraySize : %d "
                     ")",
                     size,
                     naluArraySize
                     );
        
        int naluIndex = 0;
        while( naluIndex < naluArraySize ) {
            Nalu* nalu = naluArray + naluIndex;
            naluIndex++;
            
            FileLevelLog("rtmpdump",
                         KLog::LOG_MSG,
                         "VideoRecorderH264::RecordVideoFrame( "
                         "[Got Nalu], "
                         "naluSize : %d, "
                         "naluBodySize : %d, "
                         "frameType : %d "
                         ")",
                         nalu->GetNaluSize(),
                         nalu->GetNaluBodySize(),
                         nalu->GetNaluType()
                         );
            
            // Write to H264 file
            if( mpFile ) {
                // Write NALU start code
                fwrite(sync_bytes, 1, sizeof(sync_bytes), mpFile);
                
                // Write playload
                fwrite(nalu->GetNaluBody(), 1, nalu->GetNaluBodySize(), mpFile);
                
                fflush(mpFile);
                
                bFlag = true;
            }
        }
    }
    
    return bFlag;
}
    
bool VideoRecorderH264::RecordVideoNaluFrame(const char* data, int size) {
    bool bFlag = false;
    
    // Write to H264 file
    if( mpFile ) {
        // Write NALU start code
        fwrite(sync_bytes, 1, sizeof(sync_bytes), mpFile);
        
        // Write playload
        fwrite(data, 1, size, mpFile);
        
        fflush(mpFile);
        
        bFlag = true;
    }
    
    return bFlag;
}
}
