//
//  AudioUnitNodeCreator.swift
//  AppleAudioUnit
//
//  Created by David O'Neill on 12/15/18.
//  Copyright © 2018 David O'Neill. All rights reserved.
//

public class AudioUnitNodeCreator<T: AUAudioUnit> {

    private init(){}

    public enum Result {
        case success(AVAudioUnit, T)
        case failure(Error)
    }

    public static func createAsync(description: AudioComponentDescription,
                                   name: String? = nil,
                                   options: AudioComponentInstantiationOptions = [],
                                   version: UInt32 = 1,
                                   callback: @escaping (Result) -> Void ) {

        AUAudioUnit.registerSubclass(T.self, as: description, name: name ?? NSStringFromClass(T.self), version: version)
        AVAudioUnit.instantiate(with: description, options: options) { (avAudioUnit, error) in
            guard
                let avAudioUnit = avAudioUnit,
                let auAudioUnit = avAudioUnit.auAudioUnit as? T else {
                    return callback(.failure(error ?? NSError(domain: "AppleAudioUnit", code: 0,
                                                              userInfo: [NSLocalizedDescriptionKey: "AVAudioUnit.instantiate failed"]) as Error))
            }
            callback(.success(avAudioUnit, auAudioUnit))
        }
    }

    public static func create(description: AudioComponentDescription,
                              name: String? = nil,
                              version: UInt32 = 1,
                              options: AudioComponentInstantiationOptions = []) throws -> (node: AVAudioUnit, audioUnit: T) {

        var asyncResult: Result?
        let group = DispatchGroup()
        group.enter()
        createAsync(description: description, options: options) { result in
            asyncResult = result
            group.leave()
        }
        group.wait()
        guard let result = asyncResult else { fatalError() }

        switch result {
        case let .success(node, audioUnit):
            return (node, audioUnit)
        case let .failure(error):
            throw error
        }
    }

}
