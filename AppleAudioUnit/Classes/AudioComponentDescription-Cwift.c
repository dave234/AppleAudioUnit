//
//  AudioComponentDescription-Cwift.c
//  AppleAudioUnit
//
//  Created by David O'Neill on 12/15/18.
//

#include "AudioComponentDescription-Cwift.h"

static UInt32 fourCharCode(const char *str) {
    return (UInt32)str[0] << 24 | (UInt32)str[1] << 16 | (UInt32)str[2] << 8 | (UInt32)str[3];
}

AudioComponentDescription AudioComponentDescriptionCreate(AudioComponentDescriptionType type,
                                                          FourCharCString fourCharSubType,
                                                          FourCharCString fourCharManufacturer) {

    assert(fourCharSubType != NULL &&
           strlen(fourCharSubType) == 4 &&
           "AudioComponentDescription subType not four chars!");
    
    assert(fourCharManufacturer != NULL &&
           strlen(fourCharManufacturer) == 4 &&
           "AudioComponentDescription manufacturer not four chars!");

    return (AudioComponentDescription){
        .componentType = type,
        .componentSubType = fourCharCode(fourCharSubType),
        .componentManufacturer = fourCharCode(fourCharManufacturer),
        .componentFlags = 0,
        .componentFlagsMask = 0
    };
}
