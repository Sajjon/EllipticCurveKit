import Foundation

func testData<T: Codable>(bundleType: AnyObject, jsonName: String) throws -> T {
    
    let testsDirectory: String = URL(fileURLWithPath: "\(#file)").pathComponents.dropLast(3).joined(separator: "/")
    let fileURL: URL? = URL(fileURLWithPath: "\(testsDirectory)/TestVectors/\(jsonName).json")


    let data = try Data(contentsOf: fileURL!)

    let decoder = JSONDecoder()
    let testData = try decoder.decode(T.self, from: data)

    return testData
}
