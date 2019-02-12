//
//  AudioComponentDescription-Cwift.h
//  AppleAudioUnit
//
//  Created by David O'Neill on 12/15/18.
//

#ifndef AudioComponentDescription_Cwift_h
#define AudioComponentDescription_Cwift_h

#include <stdio.h>
#include <AudioToolBox/AudioToolBox.h>
#include <Cwift/Cwift.h>

typedef enum CWIFT_ENUM AudioComponentDescriptionType {
    AudioComponentDescriptionTypeOutput           = kAudioUnitType_Output,
    AudioComponentDescriptionTypeMusicDevice      = kAudioUnitType_MusicDevice,
    AudioComponentDescriptionTypeMusicEffect      = kAudioUnitType_MusicEffect,
    AudioComponentDescriptionTypeFormatConverter  = kAudioUnitType_FormatConverter,
    AudioComponentDescriptionTypeEffect           = kAudioUnitType_Effect,
    AudioComponentDescriptionTypeMixer            = kAudioUnitType_Mixer,
    AudioComponentDescriptionTypePanner           = kAudioUnitType_Panner,
    AudioComponentDescriptionTypeGenerator        = kAudioUnitType_Generator,
    AudioComponentDescriptionTypeOfflineEffect    = kAudioUnitType_OfflineEffect,
    AudioComponentDescriptionTypeMIDIProcessor    = kAudioUnitType_MIDIProcessor
} AudioComponentDescriptionType;

// Hack for extending AudioComponentDescription with CWIFT_NAME
typedef AudioComponentDescription _AudioComponentDescriptionExtend_;

// Better hinting with a type.
typedef const char *FourCharCString;

AudioComponentDescription AudioComponentDescriptionCreate(AudioComponentDescriptionType type,
                                                          FourCharCString subType,
                                                          FourCharCString manufacturer)
CWIFT_NAME(_AudioComponentDescriptionExtend_.init(type:subType:manufacturer:));

#endif /* AudioComponentDescription_Cwift.h */
