/*-
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Copyright (c) 2024 Dong Tong Peking University
 * All rights reserved.
 * 
 * Copyright (c) 2018-2020 Alex Richardson
 * All rights reserved.
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
 * ("CTSRD"), as part of the DARPA CRASH research programme.
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory (Department of Computer Science and
 * Technology) under DARPA contract HR0011-18-C-0016 ("ECATS"), as part of the
 * DARPA SSITH research programme.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

// The following macros are expected to be defined
#define TP_FORMAT_LOWER 26
#define TP_FORMAT_UPPER 6
/* These should match the definitions in sail! */
#define TP32_TAGPTR_SIZE 4
#define TP32_TAGPTR_BITS 32
#define TP32_ADDR_WIDTH 26
#define TP32_LEN_WIDTH 27
#define TP32_MANTISSA_WIDTH 0 // in truisa, every object size is 2^E
#define TP32_MAX_EXPONENT 26  // ????
#define TP32_CURSOR_MASK 0x3FFFFFFF

#define TP32_MAX_ADDRESS_PLUS_ONE ((tp32_length_t)1u << TP32_ADDR_WIDTH)
#define TP32_NULL_TOP TP32_MAX_ADDRESS_PLUS_ONE
#define TP32_NULL_LENGTH TP32_MAX_ADDRESS_PLUS_ONE
#define TP32_MAX_LENGTH TP32_MAX_ADDRESS_PLUS_ONE
#define TP32_MAX_TOP TP32_MAX_ADDRESS_PLUS_ONE
#define TP32_MAX_ADDR TP32_MAX_ADDRESS_PLUS_ONE // 2^26

typedef uint64_t tp32_length_t;
typedef int64_t tp32_offset_t;
typedef uint32_t tp32_addr_t;
typedef int32_t tp32_saddr_t;

#include "cheri_compressed_cap_macros.h"

/* ignore ISO C restricts enumerator values to range of 'int' */
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wpedantic"
enum {
    _CC_FIELD(EXPONENT_PART, 30, 26),
    _CC_FIELD(TAGTYPE_PART, 31, 31),
};
#pragma GCC diagnostic pop

#include "cheri_compressed_cap_common.h"

#define TP32_FIELD(name, last, start) _CC_FIELD(name, last, start)

#undef TP_FORMAT_LOWER
#undef TP_FORMAT_UPPER
