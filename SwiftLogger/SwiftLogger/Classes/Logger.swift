//
//  KZLogDestination.swift
//  Pods
//
//  Created by gaoyu on 2025/2/26.
//


// MARK: - Swift 使用

/*
 Example:
    SwiftLogger.verbose("verbose")
        [02-26 18:05:03.639] RecGuideRefreshCell.refreshUI():62 💜 VERBOSE: verbose
 
    SwiftLogger.debug("debug")
        [02-26 18:05:03.639] RecGuideRefreshCell.refreshUI():63 💚 DEBUG: debug
 
    SwiftLogger.info("info")
        [02-26 18:05:03.639] RecGuideRefreshCell.refreshUI():64 💙 INFO: info
 
    SwiftLogger.warning("warning")
        [02-26 18:05:03.639] RecGuideRefreshCell.refreshUI():65 💛 WARNING: warning
 
    SwiftLogger.error("error")
        [02-26 18:05:03.639] RecGuideRefreshCell.refreshUI():66 ❤️ ERROR: error
 
    SwiftLogger.critical("critical")
        [02-26 18:05:03.639] RecGuideRefreshCell.refreshUI():67 ❤️ CRITICAL: critical
 
    SwiftLogger.fault("fault")
        [02-26 18:05:03.640] RecGuideRefreshCell.refreshUI():68 ❤️ FAULT: fault
 */

public let SwiftLogger: SwiftyBeaver.Type = {
    let log = SwiftyBeaver.self
    
    let xlog = KZLogDestination()
    xlog.format = "$N.$F:$l $C$L$c: $M"
    log.addDestination(xlog)
    
#if DEBUG
    let console = ConsoleDestination()
    console.logPrintWay = .logger(subsystem: Bundle.main.bundleIdentifier ?? "com.xiaofeng.my", category: "OGKit")
    console.format = "[$DMM-dd HH:mm:ss.SSS$d] $N.$F:$l $C$L$c: $M"
    log.addDestination(console)
#endif
    
    return log
}()


// MARK: - 暴漏给 OC 使用

@objc public class OCLogger: NSObject {
        
    @objc public static func verbose(_ log: String, file: String = #file, function: String = #function, line: Int = #line) {
        SwiftLogger.verbose(log, file: file, function: function, line: line)
    }
    
    @objc public static func debug(_ log: String, file: String = #file, function: String = #function, line: Int = #line) {
        SwiftLogger.debug(log, file: file, function: function, line: line)
    }
    
    @objc public static func info(_ log: String, file: String = #file, function: String = #function, line: Int = #line) {
        SwiftLogger.info(log, file: file, function: function, line: line)
    }
    
    @objc public static func warning(_ log: String, file: String = #file, function: String = #function, line: Int = #line) {
        SwiftLogger.warning(log, file: file, function: function, line: line)
    }
    
    @objc public static func error(_ log: String, file: String = #file, function: String = #function, line: Int = #line) {
        SwiftLogger.error(log, file: file, function: function, line: line)
    }
    
    @objc public static func critical(_ log: String, file: String = #file, function: String = #function, line: Int = #line) {
        SwiftLogger.critical(log, file: file, function: function, line: line)
    }
    
    @objc public static func fault(_ log: String, file: String = #file, function: String = #function, line: Int = #line) {
        SwiftLogger.fault(log, file: file, function: function, line: line)
    }
    
}
