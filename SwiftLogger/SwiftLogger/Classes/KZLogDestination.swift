//
//  ConsoleDestination.swift
//  SwiftyBeaver
//
//  Created by Sebastian Kreutzberger on 05.12.15.
//  Copyright © 2015 Sebastian Kreutzberger
//  Some rights reserved: http://opensource.org/licenses/MIT
//

import Foundation

class KZLogDestination: BaseDestination {
    
    public override init() {
        super.init()
        levelColor.verbose = "💜 "     // purple
        levelColor.debug = "💚 "        // green
        levelColor.info = "💙 "         // blue
        levelColor.warning = "💛 "     // yellow
        levelColor.error = "❤️ "       // red
        levelColor.critical = "❤️ "    // red
        levelColor.fault = "❤️ "       // red
    }
    
    override func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String, function: String, line: Int, context: Any? = nil) -> String? {
        let formattedString = super.send(level, msg: msg, thread: thread, file: file, function: function, line: line, context: context)
        if let message = formattedString {
            
            // 写入文件操作等...
            
        }
        return formattedString
    }
    
}
