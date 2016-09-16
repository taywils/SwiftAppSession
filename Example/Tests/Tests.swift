import XCTest
@testable import AppSession

class AppSessionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        AppSession.clear()
    }
    
    func testAppSessionClear() {
        AppSession.set("clear_me", value: 9)
        
        XCTAssertEqual(1, AppSession.count)
        
        AppSession.clear()
        
        XCTAssertEqual(0, AppSession.count)
        
        // AppSession.keys should be empty Sets after clear()
        AppSession.set("a", value: 1)
        AppSession.set("b", value: 2)
        AppSession.set("c", value: 3)
        
        XCTAssertEqual(3, AppSession.keys.count)
        
        AppSession.clear()
        XCTAssertEqual(0, AppSession.keys.count)
        
        // AppSession.groups should be empty Sets after clear()
        AppSession.set("a",         value: "A",     group: "letters")
        AppSession.set("b",         value: "B",     group: "letters")
        AppSession.set("main_dish", value: "Steak", group: "order")
        AppSession.set("side_dish", value: "Salad", group: "order")
        AppSession.set("coupon",    value: "12231", group: "order")
        
        XCTAssertEqual(2, AppSession.count)
        XCTAssertEqual(2, AppSession.keys.count)
        XCTAssertEqual(2, AppSession.groups.count)
        
        AppSession.clear()
        
        XCTAssertEqual(0, AppSession.count)
        XCTAssertEqual(0, AppSession.keys.count)
        XCTAssertEqual(0, AppSession.groups.count)
    }
    
    func testAppSessionSet() {
        let primitiveTypes:[String: Any] = [
            "int":          Int(-100),
            "uInt":         UInt(100),
            "float":        Float(100.0),
            "double":       Double(100.0),
            "bool":         false,
            "character":    Character("a"),
            "string":       String("taywils")
        ]
        
        AppSession.set("some_int", value: primitiveTypes["int"])
        XCTAssertEqual(1, AppSession.count)
        
        AppSession.set("some_uInt", value: primitiveTypes["uInt"])
        XCTAssertEqual(2, AppSession.count)
        
        AppSession.set("some_float", value: primitiveTypes["float"])
        XCTAssertEqual(3, AppSession.count)
        
        AppSession.set("some_double", value: primitiveTypes["double"])
        XCTAssertEqual(4, AppSession.count)
        
        AppSession.set("some_bool", value: primitiveTypes["bool"])
        XCTAssertEqual(5, AppSession.count)
        
        AppSession.set("some_character", value: primitiveTypes["character"])
        XCTAssertEqual(6, AppSession.count)
        
        AppSession.set("some_string", value: primitiveTypes["string"])
        XCTAssertEqual(7, AppSession.count)
        
        let array3D: [[[Int]]] = [
            [[1, 2], [3, 4]],
            [[5, 6], [7, 8]]
        ]
        
        AppSession.set("3d", value: array3D)
        XCTAssertEqual(8, AppSession.count)
    }
    
    func testAppSessionGet() {
        let primitiveType = "Bar"
        
        AppSession.set("foo", value: primitiveType)
        
        XCTAssertEqual(primitiveType, AppSession.get("foo") as? String)
        
        struct BasicStruct {
            var property: String
            
            init(property: String) {
                self.property = property
            }
        }
        let basicStruct = BasicStruct(property: "hello world")
        
        AppSession.set("basic_struct", value: basicStruct)
        
        let basicStructfromSession = AppSession.get("basic_struct") as? BasicStruct
        
        XCTAssertEqual(basicStructfromSession?.property, basicStruct.property)
        
        let array3D: [[[Int]]] = [
            [[1, 2], [3, 4]],
            [[5, 6], [7, 8]]
        ]
        
        AppSession.set("3d", value: array3D)
        
        if let array3dFromSession = AppSession.get("3d") as? [[[Int]]] {
            XCTAssertEqual(array3D[0][1], array3dFromSession[0][1])
        } else {
            XCTFail("Failed to store nested array type")
        }
    }
    
    func testAppSessionReferenceValues() {
        /* WARNING: Storing reference types within AppSession could lead to accidental state changes */
        // Create a class
        class BasicClass {
            var prop: Int
            
            init(prop: Int) {
                self.prop = prop
            }
            
            func method() -> String {
                return String(self.prop)
            }
        }
        let ogValue = 42
        let basicClass: BasicClass? = BasicClass(prop: ogValue)
        
        // Store the class in the session
        AppSession.set("basic_class", value: basicClass)
        
        XCTAssertEqual("42", (AppSession.get("basic_class") as? BasicClass)?.method())
        
        // Outside of the session update the class
        let nuValue = 777
        basicClass?.prop = nuValue
        
        // Pull the class data out from the session
        let basicClassFromSession = AppSession.get("basic_class") as? BasicClass
        
        // The class data pulled from the session should be updated since it shares a reference with the original class
        XCTAssertEqual(String(nuValue), basicClassFromSession?.method())
        XCTAssertNotEqual(String(ogValue), basicClassFromSession?.method())
    }
    
    func testAppSessionCopyValues() {
        let ogValue = "og"
        let nuValue = "nv"
        var testVar = ogValue
        
        AppSession.set("test", value: testVar)
        
        XCTAssertEqual(ogValue, AppSession.get("test") as? String)
        
        testVar = nuValue
        
        XCTAssertEqual(ogValue, AppSession.get("test") as? String)
        XCTAssertNotEqual(nuValue, AppSession.get("test") as? String)
    }
    
    func testAppSessionKeys() {
        AppSession.set("a", value: 1)
        AppSession.set("b", value: 2)
        AppSession.set("c", value: 3)
        
        XCTAssertTrue(AppSession.keys.contains("a"))
        XCTAssertTrue(AppSession.keys.contains("b"))
        XCTAssertTrue(AppSession.keys.contains("c"))
        
        XCTAssertFalse(AppSession.keys.contains("d"))
    }
    
    func testGroups() {
        AppSession.set("main_dish", value: "Pasta")
        AppSession.set("main_dish", value: "Steak", group: "order")
        AppSession.set("side_dish", value: "Salad", group: "order")
        AppSession.set("coupon",    value: "12231", group: "order")
        
        XCTAssertEqual(2, AppSession.count)
        
        let orderGroup = AppSession.get("order") as? AppSessionGroup
        XCTAssertEqual(3, orderGroup?.count)
        
        let mainDishName = orderGroup?["main_dish"] as? String
        XCTAssertEqual("Steak", mainDishName)
        
        let sideDishName = orderGroup?["side_dish"] as? String
        XCTAssertEqual("Salad", sideDishName)
        
        let couponCode = orderGroup?["coupon"] as? String
        XCTAssertEqual("12231", couponCode)
        
        AppSession.delete("order")
        XCTAssertEqual(1, AppSession.count)
    }
    
    func testKeySetWithSameNameAsExistingShouldOverwrite() {
        AppSession.set("fruit", value: "Apple")
        AppSession.set("fruit", value: "Orange")

        XCTAssertEqual("Orange", AppSession.get("fruit") as? String)
        XCTAssertEqual(1, AppSession.count)
        
        AppSession.clear()
        
        // Swap the 'AppSession.set' order
        AppSession.set("fruit", value: "Orange")
        AppSession.set("fruit", value: "Apple")

        XCTAssertEqual("Apple", AppSession.get("fruit") as? String)
        XCTAssertEqual(1, AppSession.count)
    }
    
    func testSameGroupNameAsNonGroupKeyShouldOverwrite() {
        AppSession.set("a",         value: "A", group: "letters")
        AppSession.set("b",         value: "B", group: "letters")
        AppSession.set("letters",   value: "ABC")
        
        XCTAssertEqual(1, AppSession.count)
        XCTAssertEqual("ABC", AppSession.get("letters") as? String)
        
        AppSession.clear()
        
        // Swap the 'AppSession.set' order
        AppSession.set("letters",   value: "ABC")
        AppSession.set("a",         value: "A", group: "letters")
        AppSession.set("b",         value: "B", group: "letters")

        XCTAssertEqual(1, AppSession.count)
        XCTAssertEqual(2, (AppSession.get("letters") as? AppSessionGroup)?.count)
    }
    
    func testAppSessionDelete() {
        AppSession.set("a", value: 1)
        AppSession.set("b", value: 2)
        
        AppSession.delete("a")
        XCTAssertEqual(1, AppSession.count)
        
        AppSession.delete("a")
        XCTAssertEqual(1, AppSession.count)
        
        AppSession.delete("b")
        XCTAssertEqual(0, AppSession.count)
    }
    
    func testAppSessionDeleteReferenceType() {
        /* WARNING: Storing reference types within AppSession could lead to accidental state changes */
        class BasicClass {
            var prop: Int
            
            init(prop: Int) {
                self.prop = prop
            }
            
            func method() -> String {
                return String(self.prop)
            }
        }
        let basicClass: BasicClass? = BasicClass(prop: 42)
        
        AppSession.set("bc", value: basicClass)
        
        basicClass?.prop = 53
        
        let basicClassFromSession = AppSession.get("bc") as? BasicClass
        
        AppSession.delete("bc")
        XCTAssertEqual(0, AppSession.count)
        
        XCTAssertEqual(basicClassFromSession?.method(), basicClass?.method())
    }
    
    func testAppSessionPop() {
        AppSession.set("a", value: 1)
        
        let fromSession =  AppSession.pop("a") as? Int
        XCTAssertEqual(1, fromSession)
        XCTAssertEqual(0, AppSession.count)
    }
    
    func testLowercaseSessionKeys() {
        AppSession.set("thekey", value: 22)
        
        let theValue = AppSession.get("thekey") as? Int
        let theValueAgain = AppSession.get("ThEkEy") as? Int
        
        XCTAssertEqual(theValue, theValueAgain)
        
        AppSession.set("name",      value: "taywils",   group: "user")
        AppSession.set("age",       value: 100,         group: "USER")
        AppSession.set("salary",    value: 777,         group: "uSeR")
        
        let userSession = AppSession.get("user") as? AppSessionGroup
        
        XCTAssertEqual("taywils", userSession?["name"] as? String)
        XCTAssertEqual(100, userSession?["age"] as? Int)
        XCTAssertEqual(777, userSession?["salary"] as? Int)
    }
    
    func testAppSessionContains() {
        AppSession.set("thekey", value: 22)
        
        AppSession.set("name",      value: "taywils",   group: "user")
        AppSession.set("age",       value: 100,         group: "USER")
        AppSession.set("salary",    value: 777,         group: "uSeR")
        
        AppSession.info()
        
        XCTAssertTrue(AppSession.contains("USeR"))
        XCTAssertTrue(AppSession.contains("TheKey"))

        XCTAssertFalse(AppSession.contains("wawa"))
        
        AppSession.delete("user")
        XCTAssertEqual(false, AppSession.contains("user"))
        XCTAssertEqual(1, AppSession.count)
    }
    
    func testAppSessionSetNilValue() {
        let thing: String? = nil
        
        AppSession.set("nil_value", value: thing)
        XCTAssertEqual(1, AppSession.count)
        XCTAssertTrue(AppSession.contains("nil_value"))
        XCTAssertNil(AppSession.get("nil_value") as? String)
    }
    
    func testAppSessionInfoOutput() {
        AppSession.set("thekey",    value: 22)
        AppSession.set("name",      value: "taywils",   group: "user")
        AppSession.set("age",       value: 100,         group: "USER")
        AppSession.set("salary",    value: 777,         group: "uSeR")
        AppSession.info()
        
        AppSession.set("thekey",    value: "dog")
        AppSession.set("name",      value: "taywils",   group: "user")
        AppSession.set("age",       value: 100,         group: "USER")
        AppSession.set("salary",    value: 777,         group: "uSeR")
        AppSession.info()
    }
}
