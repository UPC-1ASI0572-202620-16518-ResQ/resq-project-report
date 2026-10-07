workspace "ResQ" "Alert & Response Management - Cloud component diagram" {
    model {
        web = softwareSystem "ResQ Web Application" "Angular web application used by authorized users to review alerts and decide response authorizations."
        mobile = softwareSystem "ResQ Mobile Application" "Mobile application used by authorized users to review alerts."

        resq = softwareSystem "ResQ" "ResQ platform" {
            api = container "ResQ Cloud RESTful API" "ASP.NET Core RESTful API that provides the ResQ services." "RESTful API" {
                group "Alert & Response Management - Interface Layer" {
                    alertsController = component "AlertsController" "Exposes /api/v1/alerts: list, get and generate alerts, list response executions and decide their authorization." "REST Controller"
                    alertsFacade = component "AlertsContextFacade" "ACL that lets Risk Detection generate alerts without going through REST." "Context Facade"
                }

                group "Alert & Response Management - Application Layer" {
                    alertCommandService = component "AlertCommandService" "Generates alerts, notification deliveries and response executions after validating location and actuators." "Command Service"
                    executionCommandService = component "ResponseExecutionCommandService" "Registers the human decision on a HUMAN_REQUIRED response execution." "Command Service"
                    queryServices = component "AlertQueryService / ResponseExecutionQueryService" "Read alerts and the response executions of an alert." "Query Services"
                }

                group "Alert & Response Management - Domain Layer" {
                    alertDomain = component "Alert & Response Domain" "Alert and ResponseExecution aggregates, value objects and business rules." "Domain Model"
                }

                group "Alert & Response Management - Infrastructure Layer" {
                    persistence = component "AlertRepository / ResponseExecutionRepository" "Persist and query alerts and response executions." "EF Core Repositories"
                }

                buildingsFacade = component "BuildingsContextFacade" "Building Management ACL that validates buildings and zones." "Context Facade"
                devicesFacade = component "DevicesContextFacade" "Device Management ACL that returns device status and capabilities." "Context Facade"
                riskDetection = component "Risk Detection" "Bounded context that classifies risks and may generate alerts." "Bounded Context"
            }

            database = container "ResQ Cloud Database" "MySQL database with the alerts, notification_deliveries and response_executions tables." "MySQL"
        }

        web -> alertsController "Reviews alerts and decides authorizations through" "HTTPS/REST"
        mobile -> alertsController "Reviews alerts through" "HTTPS/REST"
        riskDetection -> alertsFacade "Generates alerts through"
        alertsController -> alertCommandService "Delegates alert generation to"
        alertsController -> executionCommandService "Delegates authorization decisions to"
        alertsController -> queryServices "Delegates queries to"
        alertsFacade -> alertCommandService "Delegates alert generation to"
        alertCommandService -> alertDomain "Creates aggregates using"
        executionCommandService -> alertDomain "Applies authorization rules using"
        alertCommandService -> buildingsFacade "Validates building and zone through"
        alertCommandService -> devicesFacade "Validates target actuators through"
        alertCommandService -> persistence "Stores alerts and executions through"
        executionCommandService -> persistence "Loads and stores executions through"
        queryServices -> persistence "Reads alerts and executions through"
        persistence -> database "Reads and writes alert data" "EF Core / MySQL"
    }

    views {
        component api "alert-response-management-cloud-component-level-diagram" "Alert & Response Management - Cloud Component Diagram" {
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
