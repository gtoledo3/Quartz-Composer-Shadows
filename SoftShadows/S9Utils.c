/*
                       __  .__              ________ 
   ______ ____   _____/  |_|__| ____   ____/   __   \
  /  ___// __ \_/ ___\   __\  |/  _ \ /    \____    /
  \___ \\  ___/\  \___|  | |  (  <_> )   |  \ /    / 
 /____  >\___  >\___  >__| |__|\____/|___|  //____/  .co.uk
      \/     \/     \/                    \/         
 
 THE GHOST IN THE CSH
 
 
S9Utils.c | Part of SoftShadows | Created 02/04/2011
 
 Copyright (c) 2010 Benjamin Blundell, www.section9.co.uk
 *** Section9 ***
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Section9 nor the names of its contributors
 *       may be used to endorse or promote products derived from this software
 *       without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * ***********************************************************************/

#include "S9Utils.h"

void generateJitterTexture(GLuint *texid, int size, int samples_u, int samples_v){ 

	glGenTextures(1, texid);

	glBindTexture(GL_TEXTURE_3D, *texid);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_REPEAT);

	signed char * data = malloc(sizeof(signed char) * size * size * samples_u * samples_v * 4 / 2 );

	for (int i = 0; i<size; i++) {
		for (int j = 0; j<size; j++) {
			for (int k = 0; k<samples_u*samples_v/2; k++) {
				
				int x, y;
				float v[4];
				
				x = k % (samples_u / 2);
				y = (samples_v - 1) - k / (samples_u / 2);
				
				// generate points on a regular samples_u x samples_v rectangular grid
				v[0] = (float)(x * 2 + 0.5f) / samples_u;
				v[1] = (float)(y + 0.5f) / samples_v;
				v[2] = (float)(x * 2 + 1 + 0.5f) / samples_u;
				v[3] = v[1];
				
				// jitter position
				v[0] += ((float)rand() * 2 / RAND_MAX - 1) * (0.5f / samples_u);
				v[1] += ((float)rand() * 2 / RAND_MAX - 1) * (0.5f / samples_v);
				v[2] += ((float)rand() * 2 / RAND_MAX - 1) * (0.5f / samples_u);
				v[3] += ((float)rand() * 2 / RAND_MAX - 1) * (0.5f / samples_v);
				
				// warp to disk
				float d[4];
				d[0] = sqrtf(v[1]) * cosf(2 * 3.1415926f * v[0]);
				d[1] = sqrtf(v[1]) * sinf(2 * 3.1415926f * v[0]);
				d[2] = sqrtf(v[3]) * cosf(2 * 3.1415926f * v[2]);
				d[3] = sqrtf(v[3]) * sinf(2 * 3.1415926f * v[2]);
				
				data[(k * size * size + j * size + i) * 4 + 0] = (signed char)(d[0] * 127);
				data[(k * size * size + j * size + i) * 4 + 1] = (signed char)(d[1] * 127);
				data[(k * size * size + j * size + i) * 4 + 2] = (signed char)(d[2] * 127);
				data[(k * size * size + j * size + i) * 4 + 3] = (signed char)(d[3] * 127);
			}
		}
	}

	glTexImage3D(GL_TEXTURE_3D, 0, GL_SIGNED_RGBA_NV, size, size, samples_u * samples_v / 2, 0, GL_RGBA, GL_BYTE, data);
	glBindTexture(GL_TEXTURE_3D, 0);
	
	free(data);
}