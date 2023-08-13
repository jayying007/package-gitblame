//
//  File.swift
//  
//
//  Created by janezhuang on 2023/8/13.
//

import Foundation

class Shell {
    public static func execute(_ command: String) -> String {
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        do {
            try task.run()
            task.waitUntilExit()
        } catch {
            print("There was an error running the command: \(command)")
            print(error.localizedDescription)
            exit(1)
        }
        
        guard let outputData = try? outputPipe.fileHandleForReading.readToEnd(),
              let outputString = String(data: outputData, encoding: .utf8) else {
            // Print error if needed
            if let errorData = try? errorPipe.fileHandleForReading.readToEnd(),
               let errorString = String(data: errorData, encoding: .utf8) {
                print("Encountered the following error running the command:")
                print(errorString)
            }
            exit(1)
        }
        
        return outputString
    }
}
