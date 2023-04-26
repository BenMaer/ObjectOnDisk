//
//  ObjectOnDisk-Tests.swift
//  ObjectOnDisk_Tests
//
//  Created by Benjamin Maer on 4/25/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest

import RxSwift

@testable import ObjectOnDisk

final class ObjectOnDisk_Tests: XCTestCase {
    func testSaveThenLoadThenDeleteClass() {
        testSaveThenLoadThenDelete(objects: [TestClass(int: 1)])
        testSaveThenLoadThenDelete(objects: [TestClass(int: 2)])
        testSaveThenLoadThenDelete(objects: [TestClass(int: 1), .init(int: 2)])
    }
    
    func testSaveThenLoadThenDeleteStruct() {
        struct TestStruct: ObjectOnDiskWrappedRequirements {
            let int: Int
        }
        
        testSaveThenLoadThenDelete(objects: [TestStruct(int: 1)])
        testSaveThenLoadThenDelete(objects: [TestStruct(int: 2)])
        testSaveThenLoadThenDelete(objects: [TestStruct(int: 1), .init(int: 2)])
    }
    
    func testSaveThenLoadThenDeleteEnum() {
        enum TestEnum: ObjectOnDiskWrappedRequirements {
            case one, two
        }
        
        testSaveThenLoadThenDelete(objects: [TestEnum.one])
        testSaveThenLoadThenDelete(objects: [TestEnum.two])
        testSaveThenLoadThenDelete(objects: [TestEnum.one, .two])
    }
}

private extension ObjectOnDisk_Tests {
    enum Step<T: ObjectOnDiskWrappedRequirements> {
        case updateObject(T?)
        case objectDidChange(_ expected: T?)
    }
    
    class TestClass: ObjectOnDiskWrappedRequirements {
        let int: Int
        init(int: Int) { self.int = int }
        static func == (lhs: TestClass, rhs: TestClass) -> Bool { lhs.int == rhs.int}
    }
    
    func testSaveThenLoadThenDelete<T: ObjectOnDiskWrappedRequirements>(objects: [T], file: StaticString = #filePath, line: UInt = #line) {
        let objectOnDiskExpectation = XCTestExpectation(description: "ObjectOnDisk should finished creating.")
        let finishedStepsExpectation = XCTestExpectation(description: "Should finished steps.")
        Self.createObjectOnDisk { objectOnDisk in
            objectOnDiskExpectation.fulfill()
            Self.testSaveThenLoadThenDelete(objectOnDisk: objectOnDisk, objects: objects, completion: {
                finishedStepsExpectation.fulfill()
            }, file: file, line: line)
        }
        wait(for: [objectOnDiskExpectation, finishedStepsExpectation], timeout: 0.1)
    }
    
    static func createObjectOnDisk<T: ObjectOnDiskWrappedRequirements>(_ completion: @escaping (ObjectOnDisk<T>) -> Void) {
        let diskInfo = DiskInfo(path: "unit-test-path")
        try? diskInfo.remove()
        
        let objectOnDisk = ObjectOnDisk<T>.init(diskInfo: diskInfo)
        objectOnDisk.loadFromDisk(completion: { completion(objectOnDisk) })
        
    }
    
    static func testSaveThenLoadThenDelete<T: ObjectOnDiskWrappedRequirements>(objectOnDisk: ObjectOnDisk<T>, objects: [T], completion: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var steps = Array(Self.steps(for: objects).reversed())
        
        let objectDidChange: (T?) -> Void = { obj in
            guard let nextStep = steps.popLast() else {
                XCTAssert(false, "object did change, but no more steps left", file: file, line: line)
                return
            }
            
            guard case let .objectDidChange(stepObj) = nextStep else {
                XCTAssert(false, "next step should be `objectDidChange`, instead was \(nextStep)", file: file, line: line)
                return
            }
            
            XCTAssert(stepObj == obj, "object did change to: \(String(describing: obj))\nbut we expected: \(String(describing: stepObj))", file: file, line: line)
        }
        
        let disposeBag = DisposeBag()
        var disposeBagPointer: DisposeBag? = disposeBag
        
        objectOnDisk.object
            .subscribe(onNext: { objectDidChange($0) })
            .disposed(by: disposeBagPointer ?? disposeBag)
        
        update(
            objectOnDisk: objectOnDisk, nextObject: {
                guard let nextStep = steps.popLast() else {
                    return nil
                }
                
                guard case let .updateObject(obj) = nextStep else {
                    XCTAssert(false, "next step should be `updateObject`, instead was \(nextStep)", file: file, line: line)
                    return nil
                }
                
                return obj
            }, completion: {
                disposeBagPointer = nil
                completion()
            },
            file: file, line: line
        )
    }
    
    static func update<T: ObjectOnDiskWrappedRequirements>(objectOnDisk: ObjectOnDisk<T>, nextObject: @escaping () -> (T??), completion: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        guard let obj = nextObject() else {
            completion()
            return
        }
        
        objectOnDisk.update(object: obj) { success in
            guard success else {
                XCTAssert(false, "failed to save object: \(String(describing: obj)): to disk info: \(objectOnDisk.diskInfo)", file: file, line: line)
                completion()
                return
            }
            
            checkObjectIsSavedToDisk(obj, diskInfo: objectOnDisk.diskInfo, file: file, line: line)
            
            update(objectOnDisk: objectOnDisk, nextObject: nextObject, completion: completion, file: file, line: line)
        }
    }
    
    static func checkObjectIsSavedToDisk<T: ObjectOnDiskWrappedRequirements>(_ object: T?, diskInfo: DiskInfo, file: StaticString = #filePath, line: UInt = #line) {
        guard diskInfo.existsOnDisk else {
            XCTAssert(object == nil, "object was saved to disk, but no file was found", file: file, line: line)
            return
        }
        
        guard let savedObject = try? diskInfo.retrieve(as: T.self) else {
            XCTAssert(false, "should have had saved object at disk info: \(diskInfo)", file: file, line: line)
            return
        }
        
        XCTAssert(savedObject == object, "saved object: \(String(describing: savedObject))\nshould equal object: \(String(describing: object))", file: file, line: line)
    }
    
    static func steps<T: ObjectOnDiskWrappedRequirements>(for objects: [T]) -> [Step<T>] {
        let stackedObjects: [[T?]] = [
            objects,
            [nil], // Set object back to nil at the end.
        ]
        
        let allObjects: [T?] = stackedObjects.flatMap({ $0 })
        
        let objectSteps: [Step<T>] = allObjects.map({[
            Step.updateObject($0),
            Step.objectDidChange($0),
        ]}).flatMap({ $0 })
        
        return [
            [.objectDidChange(nil)],
            
            objectSteps
        ].flatMap({ $0 })
    }
}
