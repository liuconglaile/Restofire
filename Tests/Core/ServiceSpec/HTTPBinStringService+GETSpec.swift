//     _____                  ____  __.
//    /  _  \ _____ _______  |    |/ _|____  ___.__.
//   /  /_\  \\__  \\_  __ \ |      < \__  \<   |  |
//  /    |    \/ __ \|  | \/ |    |  \ / __ \\___  |
//  \____|__  (____  /__|    |____|__ (____  / ____|
//          \/     \/                \/    \/\/
//
//  Copyright (c) 2016 RahulKatariya. All rights reserved.
//

import Quick
import Nimble

class HTTPBinStringGETServiceSpec: ServiceSpec {
    
    override func spec() {
        describe("StringGETService") {
            
            it("should succeed") {
                
                let actual = "Rahul Katariya"
                var expected: String!
                
                let service = HTTPBinStringGETService()
                service.parameters = ["name": "Rahul Katariya"]
                service.executeRequest() {
                    if let value = $0.value {
                        expected = value
                    }
                }
                
                expect(expected).toEventually(equal(actual), timeout: self.timeout, pollInterval: self.pollInterval)
                
            }
        }
    }
    
}
