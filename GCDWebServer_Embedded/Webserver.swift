//
//  Webserver.swift
//  GCDWebServer_Embedded
//
//  Created by Emma Walker - TVandMobile Platforms - Core Engineering on 02/03/2020.
//  Copyright © 2020 Emma Walker - TVandMobile Platforms - Core Engineering. All rights reserved.
//

import Foundation
import GCDWebServer

class Webserver {
    
    func initWebServer() {
        
        let webServer = GCDWebServer()
        
        webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: {request in
            return GCDWebServerDataResponse(html:"<html><body><p>Hello World</p></body></html>")
            
        })
        
        webServer.start(withPort: 8080, bonjourName: "GCD Web Server")
        
        print("Visit \(webServer.serverURL) in your web browser")
    }
}
