//  Copyright © 2016 Robots and Pencils, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  Neither the name of the Robots and Pencils, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Quick
import Nimble
@testable import Astro

class LogSpec: QuickSpec {
    
    override func spec() {

        class LogRecorder: Logger {
            var messages = [String]()
            
            func log(level: Log.Level, message: String) {
                messages.append(message)
            }
        }
        
        let generateLogs = { () -> () in
            Log.debug("debug")
            Log.info("info")
            Log.warn("warn")
            Log.error("error")
        }
        
        var recorder: LogRecorder!
        var defaultLogger: Logger!
        var defaultLevel: Log.Level!
        
        beforeEach {
            // remember the logger before replacing it
            defaultLogger = Log.logger
            defaultLevel = Log.level
            
            recorder = LogRecorder()
            Log.logger = recorder
        }
        afterEach {
            Log.level = defaultLevel
            Log.logger = defaultLogger
        }
        
        describe("Given we are logging at the Debug level") {
            beforeEach {
                Log.level = .Debug
                generateLogs()
            }

            it("then all messages should be logged") {
                expect(recorder.messages.count).to(equal(4))
                expect(recorder.messages).to(equal(["debug", "info", "warn", "error"]))
            }
        }
        
        describe("Given we are logging at the Info level") {
            beforeEach {
                Log.level = .Info
                
                generateLogs()
            }
            it("then all debug messages should not be logged") {
                expect(recorder.messages.count).to(equal(3))
                expect(recorder.messages).to(equal(["info", "warn", "error"]))
            }
        }
        
        describe("Given we are logging at the Warning level") {
            beforeEach {
                Log.level = .Warning
                
                generateLogs()
            }
            it("then neither debug nor info messages should not be logged") {
                expect(recorder.messages.count).to(equal(2))
                expect(recorder.messages).to(equal(["warn", "error"]))
            }
        }
        
        describe("Given we are logging at the Error level") {
            beforeEach {
                Log.level = .Error
                
                generateLogs()
            }
            it("then only error messages should be logged") {
                expect(recorder.messages.count).to(equal(1))
                expect(recorder.messages).to(equal(["error"]))
            }
        }
        
        describe("Given we are logging at the Silent level") {
            beforeEach {
                Log.level = .Silent
                
                generateLogs()
            }
            it("then nothing should be logged") {
                expect(recorder.messages.count).to(equal(0))
            }
        }
        
        struct VeryExpensiveThingToPrint : CustomStringConvertible {
            static let interval: NSTimeInterval = 100
            static let testThreshold: NSTimeInterval = 10
            
            var description: String {
                NSThread.sleepForTimeInterval(VeryExpensiveThingToPrint.interval)
                return "thing"
            }
        }
        
        describe("Given we are logging a really expensive statement") {
            
            let thing = VeryExpensiveThingToPrint()
            var logInterval: NSTimeInterval!
            
            beforeEach {
                Log.level = .Silent
                
                let start = NSDate()
                Log.debug("Really expensive log statement: \(thing)")
                
                logInterval = NSDate().timeIntervalSinceDate(start)
            }
            context("when that statement is not displayed because it's exclude by the logging level") {
                it("then it should not log anything") {
                    expect(recorder.messages.count).to(equal(0))
                }
                it("then it should not incur expensive log overhead if not actually logged") {
                    expect(logInterval).to(beLessThan(VeryExpensiveThingToPrint.testThreshold ))
                }
            }
        }
    }
}