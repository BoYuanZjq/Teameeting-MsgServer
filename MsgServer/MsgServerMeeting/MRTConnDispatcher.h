//
//  MRTConnDispatcher.h
//  MsgServerMeeting
//
//  Created by hp on 12/9/15.
//  Copyright (c) 2015 hp. All rights reserved.
//

#ifndef __MsgServerMeeting__MRTConnDispatcher__
#define __MsgServerMeeting__MRTConnDispatcher__

#include <stdio.h>
#include "RTDispatch.h"

class MRTConnDispatcher : public RTDispatch{
public:
    MRTConnDispatcher(): RTDispatch(){}
    ~MRTConnDispatcher(){}

    // for RTDispatch
    virtual void OnRecvEvent(const char*pData, int nLen);
    virtual void OnSendEvent(const char*pData, int nLen) {}
    virtual void OnWakeupEvent(const char*pData, int nLen) {}
    virtual void OnPushEvent(const char*pData, int nLen) {}
    virtual void OnTickEvent(const char*pData, int nLen);
private:

};

#endif /* defined(__MsgServerMeeting__MRTConnDispatcher__) */
