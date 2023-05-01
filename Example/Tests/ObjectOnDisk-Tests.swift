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
    
    func testIgnoreUpdateBeforeLoadFromDiskFinishes() {
        struct TestStruct: ObjectOnDiskWrappedRequirements {}
        
        let diskInfo = DiskInfo(directory: .temporary, path: "testIgnoreUpdateBeforeLoadFromDiskFinishes.data")
        try? diskInfo.remove()
        
        let objectOnDisk = ObjectOnDisk<TestStruct>(diskInfo: diskInfo)
        
        let disposeBag = DisposeBag()
        var objectDidFire = false
        
        objectOnDisk.object
            .subscribe(onNext: { object in
                guard objectDidFire == false else {
                    XCTAssertFailure("should only fire once.")
                    return
                }
                objectDidFire = true
                
                XCTAssert(object == nil, "initial object should be nil.")
            })
            .disposed(by: disposeBag)
        
        XCTAssert(objectDidFire, "should have fired on subscription.")
        
        do {
            try objectOnDisk.update(object: TestStruct())
            XCTAssertFailure("Update neighborhood should have thrown error, since we haven't loaded from disk.")
        } catch {
            XCTAssert((error as? ObjectOnDiskError.UpdateObject) == .stillLoadingFromDisk, "Should have thrown error `ObjectOnDiskError.UpdateObject.stillLoadingFromDisk`, instead got: \(error)")
        }
    }
    
    func testLoadsPreviousSave() {
        struct TestStruct: ObjectOnDiskWrappedRequirements {
            let int: Int
        }
        
        let expectation = XCTestExpectation(description: "Load previous save")
        let test = TestStruct(int: Int.random(in: (Int.min...Int.max)))
        let diskInfo = DiskInfo(directory: .temporary, path: "testLoadsPreviousSave.data")
        try? diskInfo.remove()
        Self.createObjectOnDisk(diskInfo: diskInfo) { objectOnDisk in
            Self.update(objectOnDisk: objectOnDisk, object: test) {
                Self.createObjectOnDisk(diskInfo: diskInfo) { objectOnDisk in
                    Self.test(
                        objectOnDisk: objectOnDisk,
                        steps: [.objectDidChange(test)],
                        completion: { expectation.fulfill() }
                    )
                }
            }
        }
        
        wait(for: [expectation], timeout: 0.1)
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
        static func == (lhs: TestClass, rhs: TestClass) -> Bool { lhs.int == rhs.int }
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
    
    static func createObjectOnDisk<T: ObjectOnDiskWrappedRequirements>(diskInfo: DiskInfo? = nil, _ completion: @escaping (ObjectOnDisk<T>) -> Void) {
        let diskInfo: DiskInfo = diskInfo ?? {
            let diskInfo = DiskInfo(directory: .temporary, path: "ObjectOnDisk_Tests-object.data")
            // If not specifying a disk info, then a fresh one should be blank.
            try? diskInfo.remove()
            return diskInfo
        }()
        
        let objectOnDisk = ObjectOnDisk<T>.init(diskInfo: diskInfo)
        objectOnDisk.loadFromDisk(completion: { completion(objectOnDisk) })
    }
    
    static func testSaveThenLoadThenDelete<T: ObjectOnDiskWrappedRequirements>(objectOnDisk: ObjectOnDisk<T>, objects: [T], completion: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        test(objectOnDisk: objectOnDisk, steps: Array(Self.steps(for: objects).reversed()), completion: completion, file: file, line: line)
    }
    
    static func test<T: ObjectOnDiskWrappedRequirements>(objectOnDisk: ObjectOnDisk<T>, steps: [Step<T>], completion: @escaping () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        var steps = steps
        let objectDidChange: (T?) -> Void = { obj in
            guard let nextStep = steps.popLast() else {
                XCTAssertFailure("object did change, but no more steps left", file: file, line: line)
                return
            }
            
            guard case let .objectDidChange(stepObj) = nextStep else {
                XCTAssertFailure("next step should be `objectDidChange`, instead was \(nextStep)", file: file, line: line)
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
                    XCTAssertFailure("next step should be `updateObject`, instead was \(nextStep)", file: file, line: line)
                    return nil
                }
                
                return obj
            },
            file: file, line: line, completion: {
                disposeBagPointer = nil
                completion()
            }
        )
    }
    
    static func update<T: ObjectOnDiskWrappedRequirements>(objectOnDisk: ObjectOnDisk<T>, nextObject: @escaping () -> (T??), file: StaticString = #filePath, line: UInt = #line, completion: @escaping () -> Void) {
        guard let obj = nextObject() else {
            completion()
            return
        }
        
        update(objectOnDisk: objectOnDisk, object: obj, file: file, line: line) {
            Self.update(objectOnDisk: objectOnDisk, nextObject: nextObject, file: file, line: line, completion: completion)
        }
    }
    
    static func update<T: ObjectOnDiskWrappedRequirements>(objectOnDisk: ObjectOnDisk<T>, object: T?, file: StaticString = #filePath, line: UInt = #line, completion: @escaping () -> Void) {
        do {
            try objectOnDisk.update(object: object) { success in
                guard success else {
                    XCTAssertFailure("failed to save object: \(String(describing: object)): to disk info: \(objectOnDisk.diskInfo)", file: file, line: line)
                    completion()
                    return
                }
                
                checkObjectIsSavedToDisk(object, diskInfo: objectOnDisk.diskInfo, file: file, line: line)
                
                completion()
            }
        } catch {
            XCTAssertFailure("failed to update object with error: \(error)", file: file, line: line)
        }
    }
    
    static func checkObjectIsSavedToDisk<T: ObjectOnDiskWrappedRequirements>(_ object: T?, diskInfo: DiskInfo, file: StaticString = #filePath, line: UInt = #line) {
        guard diskInfo.existsOnDisk else {
            XCTAssert(object == nil, "object was saved to disk, but no file was found", file: file, line: line)
            return
        }
        
        guard let savedObject = try? diskInfo.retrieve(as: T.self) else {
            XCTAssertFailure("should have had saved object at disk info: \(diskInfo)", file: file, line: line)
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
