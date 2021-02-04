/* -*- Mode: C; tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*- */
/*
 * arcus-memcached - Arcus memory cache server
 * Copyright 2019 JaM2in Co., Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#ifndef CHKPT_SNAPSHOT_H
#define CHKPT_SNAPSHOT_H

#ifdef ENABLE_PERSISTENCE
enum chkpt_snapshot_mode {
    CHKPT_SNAPSHOT_MODE_KEY = 0,
    CHKPT_SNAPSHOT_MODE_DATA,
    CHKPT_SNAPSHOT_MODE_CHKPT,
    CHKPT_SNAPSHOT_MODE_MAX
};

typedef void (*CB_SNAPSHOT_DONE)(void*);

ENGINE_ERROR_CODE chkpt_snapshot_init(void *engine_ptr);
void chkpt_snapshot_final(void);

ENGINE_ERROR_CODE chkpt_snapshot_direct(enum chkpt_snapshot_mode mode,
                                        const char *prefix, const int nprefix,
                                        const char *filepath, size_t *filesize);

ENGINE_ERROR_CODE chkpt_snapshot_start(enum chkpt_snapshot_mode mode,
                                       const char *prefix, const int nprefix,
                                       const char *filepath,
                                       CB_SNAPSHOT_DONE callback);
void chkpt_snapshot_stop(void);
void chkpt_snapshot_stats(ADD_STAT add_stat, const void *cookie);

int chkpt_snapshot_check_file_validity(const int fd, size_t *filesize);
int chkpt_snapshot_file_apply(const char *filepath);
#endif

#endif

