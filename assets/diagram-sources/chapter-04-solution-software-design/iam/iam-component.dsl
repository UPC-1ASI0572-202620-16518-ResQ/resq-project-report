workspace "ResQ" "Identity and Access Management component diagram" {
    model {
        web = softwareSystem "ResQ Web Application" "Web application used by authorized ResQ users to access monitoring, configuration and management capabilities."
        mobile = softwareSystem "ResQ Mobile Application" "Mobile application used by authorized ResQ users to access ResQ capabilities from mobile devices."

        resq = softwareSystem "ResQ" "ResQ platform" {
            api = container "ResQ Cloud RESTful API" "Provides the ResQ services through a RESTful API." "RESTful API" {
                group "Interface Layer" {
                    authenticationApi = component "Authentication API" "Receives authentication requests and delegates authentication use cases to the IAM Application component." "REST Controller"
                    roleAssignmentApi = component "Role Assignment API" "Receives authorized requests to assign roles to identities within an organizational scope." "REST Controller"
                    authorizationFilter = component "Authorization Filter" "Intercepts protected requests and verifies that the authenticated identity has the permission required by the requested operation." "Request Filter / Access Control Component"
                }

                group "Application Layer" {
                    iamApplication = component "IAM Application" "Coordinates authentication, role assignment and permission-checking use cases." "Application Service"
                }

                group "Domain Layer" {
                    iamDomain = component "IAM Domain" "Contains the Identity and Access Management domain model and business rules for identities, roles, permissions, role assignments and authorization." "Domain Model"
                }

                group "Infrastructure Layer" {
                    iamPersistence = component "IAM Persistence" "Implements persistence operations for identities, roles, permissions and role assignments." "Repository Adapter"
                    credentialSecurity = component "Credential Security" "Verifies authentication credentials against their protected stored representation." "Security Adapter"
                    authenticationSession = component "Authentication Session" "Creates the authenticated session representation used by ResQ clients after successful authentication." "Security Adapter"
                    organizationMembership = component "Organization Membership Integration" "Obtains the minimum information required to verify organizational membership for role assignment." "Integration Adapter"
                }
            }

            database = container "ResQ Cloud Database" "Stores persistent cloud data used by ResQ, including IAM identities, roles, permissions and role assignments." "Relational Database"
        }

        web -> authenticationApi "Authenticates users through" "HTTPS/REST"
        mobile -> authenticationApi "Authenticates users through" "HTTPS/REST"
        web -> authorizationFilter "Sends protected IAM requests through" "HTTPS/REST"
        authorizationFilter -> roleAssignmentApi "Allows authorized role-assignment requests to reach"
        authorizationFilter -> iamApplication "Requests authorization decisions from"
        authenticationApi -> iamApplication "Delegates authentication requests to"
        roleAssignmentApi -> iamApplication "Delegates role-assignment requests to"
        iamApplication -> iamDomain "Executes domain operations using"
        iamApplication -> iamPersistence "Loads and persists IAM domain state through"
        iamApplication -> credentialSecurity "Verifies authentication credentials using"
        iamApplication -> authenticationSession "Creates authenticated sessions using"
        iamApplication -> organizationMembership "Validates organizational membership through"
        iamPersistence -> database "Reads and writes IAM data" "Database access"
    }

    views {
        component api "iam-component-level-diagram" "Identity and Access Management - Component Diagram" {
            include *
            autolayout lr
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
