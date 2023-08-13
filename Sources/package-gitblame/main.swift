import Foundation
import ArgumentParser
import ShellOut

public struct package_gitblame {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

struct Blame: ParsableCommand {
    @Flag(help: "Include the line number for blame file.")
    var includeCodeLine = false

    @Option(name: .shortAndLong, help: "搜索路径，默认为当前路径")
    var searchPath: String?

    @Argument(help: "代码关键词")
    var keyword: String

    mutating func run() throws {
        let filesStr = Shell.execute("grep -Rl \(keyword) \(searchPath ?? "")")
        let files = filesStr.split(separator: "\n")
        print("包含关键字的文件有:")
        print(files)
        
        
        print("开始打印对应关键词修改者")
        for file in files {
            let blameLinesStr = try shellOut(to: ["cd \(searchPath ?? "./")", "git blame \(file) | grep \(keyword) "])
            let blameLines = blameLinesStr.split(separator: "\n")
            
            for blameLine in blameLines {
                let blameInfo = blameLine.split(separator: " ")
                let result = NSMutableString()
                
                let author = blameInfo[1]
                if (author.hasPrefix("(")) {
                    result.append(String(author[author.index(after: author.startIndex)...]))
                }
                
                let line = blameInfo[5]
                if (includeCodeLine && line.hasSuffix(")")) {
                    result.append("  " + String(line[...line.index(line.endIndex, offsetBy: -2)]))
                }
                
                print(result)
            }
        }
    }
}

Blame.main()
