workspace "ResQ" "Alert & Response Management - Edge component diagram (projected, not implemented)" {
    model {
        resq = softwareSystem "ResQ" "ResQ platform" {
            cloudApi = container "ResQ Cloud RESTful API" "Registers alerts, response executions and authorization decisions." "ASP.NET Core"

            edge = container "ResQ Edge Service" "Projected edge service for local response while the Cloud is unreachable. Not implemented." "Python / Flask" {
                group "Interface Layer" {
                    localRiskConsumer = component "Local Risk Detected Consumer" "Receives risks detected by the local Risk Detection flow." "Consumer"
                }
                group "Application Layer" {
                    edgeApplication = component "Edge Response Application" "Requests AUTOMATIC actions and keeps HUMAN_REQUIRED actions pending authorization." "Application Service"
                }
                group "Infrastructure Layer" {
                    actuatorIntegration = component "Actuator Integration" "Sends commands to the local actuators." "Integration Adapter"
                    executionPersistence = component "Edge Response Execution Persistence" "Stores local response executions." "Peewee Repository"
                    eventPublisher = component "Response Event Publisher" "Sends authorization requests and execution results to the Cloud." "Integration Adapter"
                }
            }

            edgeDatabase = container "ResQ Edge Database" "Local response execution state." "SQLite"
        }

        localRiskConsumer -> edgeApplication "Delegates locally detected risks to"
        edgeApplication -> actuatorIntegration "Requests actuator commands through"
        edgeApplication -> executionPersistence "Stores execution state through"
        edgeApplication -> eventPublisher "Publishes authorization requests and results through"
        executionPersistence -> edgeDatabase "Reads and writes executions" "Peewee / SQLite"
        eventPublisher -> cloudApi "Sends authorization requests and results to" "HTTPS"
    }

    views {
        component edge "alert-response-management-edge-component-level-diagram" "Alert & Response Management - Edge Component Diagram (projected)" {
            include *
            autolayout tb
        }
        styles {
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
        }
    }
}
