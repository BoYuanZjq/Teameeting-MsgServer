//
//  SRTStorageRedis.cpp
//  dyncRTStorage
//
//  Created by hp on 11/26/15.
//  Copyright (c) 2015 hp. All rights reserved.
//

#include "SRTStorageRedis.h"
#include "SRTRedisGroup.h"
#include "OSThread.h"

static int g_push_event_counter = 0;
static OSMutex      g_push_event_mutex;

static unsigned int APHash(const char *str) {
    unsigned int hash = 0;
    int i;
    for (i=0; *str; i++) {
        if ((i&  1) == 0) {
            hash ^= ((hash << 7) ^ (*str++) ^ (hash >> 3));
        } else {
            hash ^= (~((hash << 11) ^ (*str++) ^ (hash >> 5)));
        }
    }
    return (hash&  0x7FFFFFFF);
}

enum {
 CACHE_TYPE_1,
 CACHE_TYPE_2,
 CACHE_TYPE_MAX,
};

void SRTStorageRedis::Init(SRTRedisGroup* group, const std::string& ip, int port)
{
    //LI("SRTStorageRedis::Init was called, ip:%s, port:%d\n", ip.c_str(), port);
    m_Ip = ip;
    m_Port = port;
    m_RedisGroup = group;

    m_RedisList = new RedisNode;
    m_RedisList->dbindex = 0;
    m_RedisList->host = m_Ip.c_str();
    m_RedisList->port = m_Port;
    m_RedisList->passwd = "";
    m_RedisList->poolsize = 8;
    m_RedisList->timeout = 5;
    m_RedisList->role = 0;

    m_xRedisClient.Init(CACHE_TYPE_MAX);
    m_xRedisClient.ConnectRedisCache(m_RedisList, 1, CACHE_TYPE_1);
    m_RedisDBIdx = new RedisDBIdx(&m_xRedisClient);
}

void SRTStorageRedis::Unin()
{
    //LI("SRTStorageRedis::Unin was called, host:%s\n", GetHostForTest().c_str());
    m_RedisGroup = nullptr;
    if (m_RedisList)
    {
        delete m_RedisList;
        m_RedisList = nullptr;
    }
    if (m_RedisDBIdx)
    {
         delete m_RedisDBIdx;
         m_RedisDBIdx = nullptr;
    }
}

// from RTEventLooper

// for read
void SRTStorageRedis::OnWakeupEvent(const void*pData, int nSize)
{
    if (m_QueuePostMsg.size()==0) return;
    pms::StorageMsg store = m_QueuePostMsg.front();
    if (store.mflag()==pms::EMsgFlag::FGROUP)
    {
        std::string str("");
        char key[512] = {'\0'};
        sprintf(key, "grp:%s:%lld", store.storeid().c_str(), store.sequence());
        m_RedisDBIdx->CreateDBIndex(key, APHash, CACHE_TYPE_1);
        if (m_xRedisClient.exists(*m_RedisDBIdx, key))
        {
            m_xRedisClient.get(*m_RedisDBIdx, key, str);
            store.set_result(0);
            *store.mutable_content() = str;
        } else {
            store.set_result(-1);// key is not exists
            *store.mutable_content() = str;
        }
        printf("SRTStorageRedis::OnWakeupEvent g read key:%s, msgid:%s, storeid:%s, seqn:%lld, maxseqn:%lld, result:%d\n"\
                , key\
                , store.msgid().c_str()\
                , store.storeid().c_str()\
                , store.sequence()\
                , store.maxseqn()\
                , store.result());

    } else if (store.mflag()==pms::EMsgFlag::FSINGLE)
    {
        std::string str("");
        char key[512] = {'\0'};
        sprintf(key, "sgl:%s:%lld", store.storeid().c_str(), store.sequence());
        m_RedisDBIdx->CreateDBIndex(key, APHash, CACHE_TYPE_1);
        if (m_xRedisClient.exists(*m_RedisDBIdx, key))
        {
            m_xRedisClient.get(*m_RedisDBIdx, key, str);
            store.set_result(0);
            *store.mutable_content() = str;
        } else {
            store.set_result(-1);// key is not exists
            *store.mutable_content() = str;
        }
        printf("SRTStorageRedis::OnWakeupEvent s read key:%s, msgid:%s, storeid:%s, seqn:%lld, maxseqn:%lld, result:%d\n"\
                , key\
                , store.msgid().c_str()\
                , store.storeid().c_str()\
                , store.sequence()\
                , store.maxseqn()\
                , store.result());
    } else {
        printf("SRTStorageRedis::OnWakeupEvent mflag:%d error\n", store.mflag());
        assert(false);
    }
    if (m_RedisGroup)
    {
        m_RedisGroup->PostData(store.SerializeAsString());
        {
            OSMutexLocker locker(&m_MutexRecvPush);
            m_QueuePostMsg.pop();
        }
    } else {
        assert(false);
    }
    if (m_QueuePostMsg.size()>0)
    {
        this->Signal(Task::kWakeupEvent);
    }
}

// for write
void SRTStorageRedis::OnTickEvent(const void*pData, int nSize)
{
    printf("SRTStorageRedis::OnTickEvent for write...\n");
    if (m_QueuePushMsg.size()==0) return;
    pms::StorageMsg store = m_QueuePushMsg.front();
    if (store.mflag()==pms::EMsgFlag::FGROUP)
    {
        char key[512] = {'\0'};
        sprintf(key, "grp:%s:%lld", store.storeid().c_str(), store.sequence());
        m_RedisDBIdx->CreateDBIndex(key, APHash, CACHE_TYPE_1);

        printf("SRTStorageRedis::OnTickEvent g result:%d, storeid:%s, msgid:%s\n"\
                , store.result()\
                , store.storeid().c_str()\
                , store.msgid().c_str());
        {
            if (m_xRedisClient.set(*m_RedisDBIdx, key, store.content().c_str()))
            {
                store.set_result(0);
            } else {
                printf("SRTStorageRedis::OnTickEvent g write group msg error\n");
                assert(false);
            }
        }
        printf("SRTStorageRedis::OnTickEvent g write key:%s, msgid:%s, storeid:%s, seqn:%lld, maxseqn:%lld, result:%d\n"\
                , key\
                , store.msgid().c_str()\
                , store.storeid().c_str()\
                , store.sequence()\
                , store.maxseqn()\
                , store.result());
    } else if (store.mflag()==pms::EMsgFlag::FSINGLE)
    {
        char key[512] = {'\0'};
        sprintf(key, "sgl:%s:%lld", store.storeid().c_str(), store.sequence());
        m_RedisDBIdx->CreateDBIndex(key, APHash, CACHE_TYPE_1);

        printf("SRTStorageRedis::OnTickEvent s result:%d, storeid:%s, msgid:%s\n"\
                , store.result()\
                , store.storeid().c_str()\
                , store.msgid().c_str());
        {
            if (m_xRedisClient.set(*m_RedisDBIdx, key, store.content().c_str()))
            {
                store.set_result(0);
            } else {
                printf("SRTStorageRedis::OnTickEvent s write group msg error\n");
                assert(false);
            }
        }
        printf("SRTStorageRedis::OnTickEvent s write key:%s, msgid:%s, storeid:%s, seqn:%lld, maxseqn:%lld, result:%d\n"\
                , key\
                , store.msgid().c_str()\
                , store.storeid().c_str()\
                , store.sequence()\
                , store.maxseqn()\
                , store.result());
    } else {
        printf("SRTStorageRedis::OnTickEvent mflag:%d error\n", store.mflag());
        assert(false);
    }

    if (m_RedisGroup)
    {
        m_RedisGroup->PushData(store.SerializeAsString());
        {
            OSMutexLocker locker(&m_MutexRecvPush);
            m_QueuePushMsg.pop();
        }
    } else {
         assert(false);
    }
    if (m_QueuePushMsg.size()>0)
    {
        this->Signal(Task::kIdleEvent);
    }
}

// for write
void SRTStorageRedis::PushToQueue(pms::StorageMsg request)
{
    {
        OSMutexLocker locker(&m_MutexRecvPush);
        m_QueuePushMsg.push(request);
    }
    this->Signal(Task::kIdleEvent);
}

// for read
void SRTStorageRedis::PostToQueue(pms::StorageMsg request)
{
    {
        OSMutexLocker locker(&m_MutexRecvPush);
        m_QueuePostMsg.push(request);
    }
    this->Signal(Task::kWakeupEvent);
}

///////////////////////////////////////////////////////
