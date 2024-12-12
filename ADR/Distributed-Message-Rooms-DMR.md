# Architectural Decision Record (ADR) for Distributed Message Rooms (DMR)

## ADR-001: Stateless Architecture for Distributed Message Rooms

### **Context**
The system must ensure that each Distributed Message Room (DMR) operates independently without shared state to achieve simplicity, scalability, and maintainability. Statelessness ensures horizontal scalability and eliminates dependencies between instances.

### **Decision**
- DMRs will not maintain state between requests.
- All message data, metadata, and routing information must be self-contained within each request.

### **Consequences**
- **Scalability**: Statelessness allows seamless addition or removal of DMR instances.
- **Simplicity**: Eliminates the need for shared storage or synchronization mechanisms.
- **Reliability**: Reduces points of failure related to state consistency.
- **Increased Responsibility on Sender**: The sender must ensure all required information is included in each request.

---

## ADR-002: Nginx as the Primary Router for DMRs

### **Context**
Efficient routing is critical for ensuring reliable message delivery between DMRs. Nginx provides advanced routing capabilities, high performance, and robust failover mechanisms, making it suitable for this purpose.

### **Decision**
- Nginx will be used as the primary router for message delivery.
- Failover mechanisms will be configured to handle retries for failed DMRs.
- Advanced Nginx configuration options will be leveraged for efficient message routing.

### **Consequences**
- **Reliability**: Nginx ensures robust routing with failover capabilities.
- **Performance**: High throughput and low latency in message delivery.
- **Complexity**: Advanced configurations may require specialized knowledge.
- **Dependence on Nginx**: The system becomes reliant on Nginx for routing functionality.

---

## ADR-003: Avoidance of Databases or Message Queues in Real-Time Execution

### **Context**
To maintain simplicity and reduce operational overhead, the system will not rely on databases or message queues for real-time message execution. Instead, all required information will be included in the message payload, and retries will be handled directly by the sender.

### **Decision**
- Databases and message queues will not be used in real-time execution.
- Message payloads will include all necessary data for routing and processing.
- Retry mechanisms will be managed at the sender level.

### **Consequences**
- **Simplicity**: Eliminates dependencies on external systems for real-time operations.
- **Reliability**: Reduces points of failure by avoiding additional infrastructure.
- **Increased Responsibility on Sender**: The sender must handle retries and ensure message completeness.
- **Scalability**: Simplifies scaling as no centralized database or message queue is required.

---

## ADR-004: Security Measures for DMR Communication

### **Context**
Security is critical for ensuring that only authorized participants can access and use the DMR system. Strong encryption, authentication, and access control mechanisms are required to prevent unauthorized access and mitigate risks such as denial-of-service attacks.

### **Decision**
- All communications will use TLS encryption.
- Certificate-based authentication will be enforced.
- IP-based access restrictions will be implemented.
- Rate-limiting and request validation will mitigate denial-of-service attacks.

### **Consequences**
- **Security**: Ensures that communications are encrypted and authenticated.
- **Resilience**: Protects the system against unauthorized access and abuse.
- **Complexity**: Requires proper certificate management and access control configurations.

---

## ADR-005: Logging and Monitoring for Traceability

### **Context**
Comprehensive logging and monitoring are essential for troubleshooting, performance optimization, and ensuring system reliability. Logs must include sufficient metadata to trace requests and responses and support proactive issue detection.

### **Decision**
- All requests, responses, and retries will be logged with sufficient metadata.
- Centralized logging tools will be implemented for analysis and reporting.
- Logs will include details of failed requests to enable automated retries or manual intervention.

### **Consequences**
- **Observability**: Simplifies troubleshooting and performance analysis.
- **Proactivity**: Enables early detection of issues through detailed logs.
- **Overhead**: Requires resources to maintain and process logs.

---

## ADR-006: Kubernetes Deployment for High Availability

### **Context**
High availability is essential for ensuring that the DMR system remains operational even during updates or instance failures. Kubernetes provides robust features for auto-scaling, rolling updates, and fault tolerance.

### **Decision**
- Deploy DMRs as Kubernetes pods with auto-scaling and rolling updates.
- Use Helm charts or similar tools for consistent deployment configurations.

### **Consequences**
- **Availability**: Ensures zero-downtime updates and fault tolerance.
- **Scalability**: Simplifies scaling to meet demand.
- **Operational Overhead**: Requires expertise in Kubernetes and related tooling.

---

## ADR-007: Centralized Coordination for Health Reporting and Validation

### **Context**
A centralized system is needed to manage the health status of DMR instances and validate participants. This system will ensure that DMRs are functioning correctly and that only authorized participants can communicate.

### **Decision**
- Each DMR instance will report its health status to a centralized "home" system.
- The "home" system will maintain the list of validated participants and distribute updates to DMRs.
- A lightweight heartbeat mechanism will ensure real-time status monitoring.

### **Consequences**
- **Reliability**: Ensures that the system can detect and respond to health issues.
- **Security**: Centralized validation ensures only authorized participants can communicate.
- **Dependency**: The system relies on the availability of the centralized "home" system.

---

## ADR-008: Dynamic Participant Validation

### **Context**
Participants in the DMR system must be validated dynamically to accommodate changes in participant status without downtime. Validation mechanisms should be secure and efficient.

### **Decision**
- Use a dynamic participant list validated via JSON Web Tokens (JWTs) or signed certificates.
- Participant lists will be updated centrally and synced with all DMRs without downtime.

### **Consequences**
- **Flexibility**: Enables real-time updates to participant validation.
- **Security**: Ensures that only authorized participants are allowed.
- **Complexity**: Requires robust synchronization mechanisms to ensure consistency.

---


## ADR-009: Fallback Strategy for Failed Requests

### **Context**
Retries are critical to ensuring message delivery in case of temporary DMR failures. However, prolonged or repeated failures should not overload the system. A fallback strategy is required to define maximum retry limits and manage unresolved failures effectively.

### **Decision**
- Define a maximum retry count (e.g., 3 attempts) after which the request is sent to another instance of DMR, or the sender marks the request as failed.
- Notify the central "home" system of the failure for manual intervention if required.
- Optionally notify the user about the failed request.

### **Consequences**
- **Reliability**: Ensures that temporary failures are retried within a reasonable limit.
- **System Protection**: Prevents the system from being overloaded by repeated retries.
- **Manual Oversight**: Allows unresolved failures to be addressed manually if necessary.
- **User Awareness**: Provides transparency to users about the state of their requests.

---
