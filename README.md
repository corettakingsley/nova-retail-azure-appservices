\# Nova Retail – Azure App Services Architecture



\## Project Overview



Nova Retail is a cloud infrastructure project designed to deploy a modern, secure and scalable retail application on Microsoft Azure.



The project uses \*\*Infrastructure as Code (IaC)\*\* with Terraform to provision and manage Azure resources.



The architecture separates the frontend, backend and database layers to support independent deployment, improved maintainability, security and troubleshooting.



This is the second Nova Retail infrastructure implementation. It follows the earlier VM-based architecture, but introduces Azure managed services through Azure App Services.



\*\*Project status:\*\* Infrastructure configuration in progress. Azure deployment has not yet taken place.



\## Technology Stack



| Component | Technology |

|---|---|

| Cloud Platform | Microsoft Azure |

| Infrastructure as Code | Terraform |

| Frontend Hosting | Azure Linux App Service |

| Backend Hosting | Azure Linux App Service |

| Frontend Runtime | Node.js 22 LTS |

| Backend Runtime | Python 3.12 |

| Database | Azure Database for MySQL Flexible Server |

| Network Security | Azure Virtual Network, NSGs, Private Endpoints |

| Web Application Firewall | Azure Application Gateway WAF\_v2 |

| Secrets Management | Azure Key Vault |

| Identity | Microsoft Entra ID – Managed Identity |

| Monitoring | Azure Monitor, Log Analytics, Application Insights |

| Source Control | GitHub |



\## Architecture Overview



The solution is designed around a multi-tier architecture:



1\. \*\*Presentation layer:\*\* Vue.js frontend hosted on Azure App Service.

2\. \*\*Application layer:\*\* FastAPI backend hosted separately on Azure App Service.

3\. \*\*Data layer:\*\* Azure Database for MySQL Flexible Server using private networking.

4\. \*\*Security layer:\*\* Application Gateway WAF, Private Endpoints, Managed Identity and Key Vault.

5\. \*\*Monitoring layer:\*\* Log Analytics, Application Insights and Azure diagnostic settings.



\### Request Flow



```mermaid

flowchart TD

&#x20;   U\[Internet Users] --> GW\[Azure Application Gateway WAF\_v2]

&#x20;   GW -->|Default route /| FE\[Frontend App Service]

&#x20;   GW -->|/api/\*| BE\[Backend App Service]

&#x20;   FE -.->|Private Endpoint| VNET\[Azure Virtual Network]

&#x20;   BE -.->|Private Endpoint| VNET

&#x20;   BE -->|VNet Integration| DB\[MySQL Flexible Server]

&#x20;   BE --> KV\[Key Vault]

&#x20;   DB --> DNS\[Private DNS]

&#x20;   KV --> DNS

&#x20;   MON\[Azure Monitor and Log Analytics] -.-> GW

&#x20;   MON -.-> FE

&#x20;   MON -.-> BE

&#x20;   MON -.-> DB

```



\## Azure Infrastructure



\### 1. Resource Group and Networking



The infrastructure is planned for the South Africa North Azure region.



\- Resource Group: `nova-retail-rg`

\- Virtual Network: `nova-retail-vnet`

\- Address Space: `10.30.0.0/16`



| Subnet | Address Range | Purpose |

|---|---|---|

| snet-appgw | 10.30.1.0/24 | Application Gateway |

| snet-appsvc-integration | 10.30.10.0/24 | Backend App Service VNet Integration |

| snet-mysql-delegated | 10.30.20.0/24 | MySQL Flexible Server |

| snet-private-endpoints | 10.30.30.0/24 | Private Endpoints |



The subnet design separates application traffic, database connectivity, gateway infrastructure and private service access.



\### 2. Application Hosting



Two independent Linux App Services are configured:



\*\*Frontend\*\*

\- Azure Linux App Service

\- Node.js 22 LTS

\- Basic B1 App Service Plan

\- System-assigned Managed Identity

\- Public network access disabled

\- Private Endpoint connectivity



\*\*Backend\*\*

\- Azure Linux App Service

\- Python 3.12

\- Basic B1 App Service Plan

\- System-assigned Managed Identity

\- Public network access disabled

\- Private Endpoint connectivity

\- Regional VNet Integration for private outbound connectivity



The frontend and backend use separate App Service Plans to maintain deployment and scaling independence.



\### 3. Application Gateway and WAF



Azure Application Gateway WAF\_v2 is configured as the public entry point.



Planned capabilities include:



\- Standard static public IP address.

\- WAF\_v2 autoscaling configuration.

\- Minimum capacity: 1.

\- Maximum capacity: 2.

\- WAF Prevention mode.

\- OWASP Core Rule Set 3.2.

\- Path-based routing.



Routing design:



| Path | Destination |

|---|---|

| `/` | Frontend App Service |

| `/api/\*` | Backend App Service |



The current configuration uses an HTTP public listener on port 80 and HTTPS connections from the gateway to the App Service backends. Public HTTPS and certificate configuration remain future implementation work.



\### 4. Private Networking



Private connectivity is a key design principle.



The architecture uses:



\- Private Endpoints for frontend and backend App Services.

\- Private Endpoint for Azure Key Vault.

\- Private DNS zone for App Services: `privatelink.azurewebsites.net`.

\- Private DNS zone for Key Vault: `privatelink.vaultcore.azure.net`.

\- Private DNS zone for MySQL Flexible Server.

\- VNet Integration for backend outbound connectivity.

\- Delegated subnet for MySQL Flexible Server.

\- Public network access disabled for the App Services, Key Vault and MySQL server.



MySQL uses delegated VNet integration rather than a Private Endpoint.



\### 5. Database



The application database is Azure Database for MySQL Flexible Server.



Planned configuration:



\- MySQL 8.0.21.

\- Burstable B1ms compute tier.

\- 32 GB storage.

\- Seven-day backup retention.

\- Geo-redundant backups disabled.

\- Private networking.

\- Public network access disabled.



Slow query logging and database audit logging are also configured through Terraform.



\### 6. Security and Identity



Security is incorporated into the infrastructure design rather than treated as an additional deployment task.



Controls include:



\- Azure Application Gateway WAF\_v2.

\- Network Security Group on the Application Gateway subnet.

\- Private Endpoints for private inbound service connectivity.

\- Disabled public network access on selected services.

\- Azure Key Vault with RBAC authorization.

\- System-assigned Managed Identities.

\- Key Vault Secrets User role assignment for the backend identity.

\- Key Vault soft delete and purge protection.

\- HTTPS-only settings on both App Services.



The backend will use Managed Identity to access authorized Key Vault secrets without embedding credentials in application configuration.



\### 7. Monitoring and Observability



The monitoring architecture includes:



\- Azure Log Analytics Workspace.

\- Workspace-based Application Insights.

\- Application Gateway access logs.

\- WAF firewall logs.

\- App Service HTTP logs.

\- App Service console and platform logs.

\- Key Vault audit events.

\- MySQL audit and slow query logs.

\- Azure resource metrics.



The Log Analytics Workspace is configured with 30-day retention.



\## Terraform Repository Structure



```text

nova-retail-azure-appservices/

│

├── .gitignore

├── .terraform.lock.hcl

├── main.tf

├── variables.tf

├── network.tf

├── app-services.tf

├── application-gateway.tf

├── private-networking.tf

├── database.tf

├── key-vault.tf

├── security.tf

└── monitoring.tf

```



Each Terraform file separates a major infrastructure responsibility to improve maintainability and troubleshooting.



\## Deployment Approach



The infrastructure will be provisioned using Terraform.



Planned workflow:



1\. Authenticate with Azure.

2\. Initialize Terraform providers.

3\. Format and validate Terraform configuration.

4\. Review resource availability and regional compatibility.

5\. Generate and review the Terraform execution plan.

6\. Review projected Azure costs.

7\. Obtain deployment approval.

8\. Deploy approved infrastructure.

9\. Verify private connectivity, application routing and security.

10\. Configure application deployment and monitoring.



Example Terraform validation commands:



```powershell

terraform init

terraform fmt -check

terraform validate

terraform plan

```



Terraform state files, credentials and variable files containing secrets must not be committed to GitHub.



\## Cost Management



Cost control is an important project requirement.



The infrastructure is designed with development workloads in mind, using Basic App Service Plans and a Burstable MySQL configuration.



However, Azure Application Gateway WAF\_v2, private networking, monitoring and database resources can generate ongoing charges.



Resource pricing, regional availability and service compatibility will be reviewed before deployment.



No Azure resources should be provisioned without reviewing the execution plan and obtaining approval.



\## Current Project Status



\- \[x] Terraform configuration created.

\- \[x] Terraform provider lock file included.

\- \[x] Separate GitHub repository established.

\- \[x] Initial Terraform commit pushed.

\- \[x] Terraform configuration organized by infrastructure component.

\- \[ ] README and architecture documentation.

\- \[ ] Full Terraform configuration review.

\- \[ ] Regional SKU and pricing verification.

\- \[ ] Terraform plan review.

\- \[ ] Azure infrastructure deployment.

\- \[ ] Application deployment.

\- \[ ] End-to-end connectivity and security testing.

\- \[ ] Operational documentation and evidence.



\## Project Objectives



This project demonstrates practical cloud engineering capabilities in:



\- Microsoft Azure infrastructure architecture.

\- Terraform and Infrastructure as Code.

\- Azure networking and private connectivity.

\- Application Gateway and Web Application Firewall.

\- Managed identities and secrets management.

\- Database security and private access.

\- Cloud monitoring and observability.

\- Infrastructure cost management.

\- Git-based infrastructure version control.



\---



\*\*Project:\*\* Nova Retail – Azure App Services Architecture  

\*\*Cloud Provider:\*\* Microsoft Azure  

\*\*Infrastructure as Code:\*\* Terraform  

\*\*Repository:\*\* https://github.com/corettakingsley/nova-retail-azure-appservices  

\*\*Status:\*\* In Progress

