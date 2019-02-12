//
//  AAUDsp.h
//  Pods
//
//  Created by David O'Neill on 2/10/19.
//

#ifndef AAUDsp_h
#define AAUDsp_h

#include <Cwift/Cwift.h>

typedef void *AAUDsp CWIFT_TYPE;

typedef void (*AAUDspRenderCallback)(AAUDsp     dsp,
                                     float      **inChannels,
                                     float      **outChannels,
                                     int        channelCount,
                                     int        frameCount,
                                     float      *parameters);

typedef void (*AAUDspMidiCallback)(AAUDsp           dsp,
                                   unsigned char    *midi,
                                   int              length,
                                   int              isSysEx);

typedef void (*AAUDspAllocateCallback)(AAUDsp   dsp,
                                       float    sampleRate,
                                       float    channelCount,
                                       int      maximumFramesPerRender);

typedef void (*AAUDspReleaseCallback)(AAUDsp    renderer);

#endif /* AAUDsp_h */
