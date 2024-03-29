import Sh
import o

public struct Project {
    public init() {}
    
    public func generate() throws {
        let resourcePath = "./SPX/Sources/ProjectLib/Resources"
        let filename: String
        let header: String
        
        if "BASE".lowercased() == "OpenWeather"  {
            filename = "OpenBytesHeader.txt"
        } else {
            filename = "StandardHeader.txt"
        }
        
        header = String(
            data: try o.file.data(
                path: resourcePath,
                filename: filename
            ),
            encoding: .utf8
        ) ?? ""
        
        try sh(.terminal, "xcodegen")
        try shq(.terminal, "echo '\(header)' > OpenWeather.xcodeproj/xcshareddata/IDETemplateMacros.plist")
    }
}
