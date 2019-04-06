//
//  AVAudioUnitCreator.swift
//  AppleAudioUnit
//
//  Created by David O'Neill on 12/15/18.
//  Copyright © 2018 David O'Neill. All rights reserved.
//

public class AVAudioUnitCreator<T: AUAudioUnit> {

    private init(){}

    public struct NodeUnit<T: AUAudioUnit> {
        public let node: AVAudioUnit // Inherits from AVAudioNode, naming is weak here.
        public let unit: T
    }

    public static func createAsync(description: AudioComponentDescription,
                                   name: String? = nil,
                                   options: AudioComponentInstantiationOptions = [],
                                   version: UInt32 = 1,
                                   callback: @escaping (Result<NodeUnit<T>, Error>) -> Void ) {

        AUAudioUnit.registerSubclass(T.self, as: description, name: name ?? NSStringFromClass(T.self), version: version)
        AVAudioUnit.instantiate(with: description, options: options) { (avAudioUnit, error) in
            guard
                let avAudioUnit = avAudioUnit,
                let auAudioUnit = avAudioUnit.auAudioUnit as? T else {
                    return callback(.failure(error ?? NSError(domain: "AppleAudioUnit", code: 0,
                                                              userInfo: [NSLocalizedDescriptionKey: "AVAudioUnit.instantiate failed"]) as Error))
            }
            callback(.success(NodeUnit(node: avAudioUnit, unit: auAudioUnit)))
        }
    }

    public static func create(description: AudioComponentDescription,
                              name: String? = nil,
                              version: UInt32 = 1,
                              options: AudioComponentInstantiationOptions = []) throws -> NodeUnit<T> {

        var asyncResult: Result<NodeUnit<T>, Error>?
        let group = DispatchGroup()
        group.enter()
        createAsync(description: description, options: options) { result in
            asyncResult = result
            group.leave()
        }
        group.wait()
        guard let syncResult = asyncResult else { fatalError() }

        switch syncResult {
        case .success(let nodeUnit):
            return NodeUnit(node: nodeUnit.node, unit: nodeUnit.unit)
        case let .failure(error):
            throw error
        }
    }

}
