/*
 * arcus-memcached - Arcus memory cache server
 * Copyright 2010-2014 NAVER Corp.
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
#ifndef CONFIG_PARSER_H
#define CONFIG_PARSER_H

#include <stdio.h> // for using FILE structure.
#include <stdint.h>
#include <memcached/visibility.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * The supported datatypes the config file parser can handle
 */
enum config_datatype {
   DT_SIZE,
   DT_UINT32,
   DT_FLOAT,
   DT_BOOL,
   DT_STRING,
   DT_CONFIGFILE,
   DT_CHAR
};

/**
 * I don't like casting, so let's create a union to keep all the values in
 */
union config_value {
   size_t *dt_size;
   uint32_t *dt_uint32;
   float *dt_float;
   bool *dt_bool;
   char **dt_string;
   char *dt_char;
};

/**
 * An entry for a single item in the config file.
 */
struct config_item {
   /** The name of the key */
   const char* key;
   /** The datatype for the value */
   enum config_datatype datatype;
   /** Where to store the value from the config file */
   union config_value value;
   /** If the item was found in the config file or not */
   bool found;
};

/**
 * Parse the configuration argument and populate the values into the
 * config items.
 *
 * @param str the encoded configuration string
 * @param items the config items to look for
 * @param error stream to write error messages to
 * @return 0 if config successfully parsed
 *         1 if config successfully parsed, but unknown tokens found
 *        -1 if illegal values was found in the config
 */
MEMCACHED_PUBLIC_API int parse_config(const char *str, struct config_item items[], FILE *error);

#ifdef __cplusplus
}
#endif

#endif
