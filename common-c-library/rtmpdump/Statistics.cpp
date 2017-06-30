//
//  Statistics.cpp
//  RtmpClient
//
//  Created by Max on 2017/6/23.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#include "Statistics.h"

namespace coollive {
Statistics::Statistics() {
    
}
    
Statistics::~Statistics() {
    
}
    
void Statistics::SetVideoDecoder(VideoDecoder* decoder) {
    mpDecoder = decoder;
}
    
void Statistics::SetRtmpPlayer(RtmpPlayer* player) {
    mpPlayer = player;
}

bool Statistics::IsDropVideoFrame() {
    bool bFlag = false;
    return bFlag;
}
}
