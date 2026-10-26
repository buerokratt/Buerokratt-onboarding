# Data journey

How a question travels through Bürokratt. Component names match the [overview diagram](README.md#overview).

## 1. An end user gets an answer

The answer comes from an LLM (currently Azure OpenAI) and reaches the widget as a stream. The diagram is simplified: Ruuter also runs intent detection and can trigger a service instead of asking the LLM.

```mermaid
sequenceDiagram
  autonumber
  actor Client as End user
  participant Widget as Chat-Widget
  participant Ruuter as Ruuter public
  participant Resql
  participant Anonymizer
  participant Notif as notifications-node
  participant OpenSearch
  participant LLM

  Client->>Widget: Question
  Widget->>Ruuter: Question (REST)
  Ruuter->>Resql: Load the conversation so far
  Resql-->>Ruuter: Messages
  opt Anonymisation is enabled
    Ruuter->>Anonymizer: Messages
    Anonymizer-->>Ruuter: Messages without personal data
  end
  Ruuter->>Notif: Start a stream for this chat
  Notif->>LLM: Messages (HTTPS)
  LLM-->>Notif: Answer, token by token
  Notif-->>Widget: Answer (SSE stream)
  Notif->>OpenSearch: Store conversation state
  Widget-->>Client: Answer
```

When the LLM module is enabled for the installation, notifications-node requests the stream from the LLM Orchestration Service in LLM-Module instead of calling the LLM directly.

## 2. Another agency answers: the Bürokratt network

If one agency's Bürokratt cannot answer, it asks the network who can. The user must agree before the conversation is redirected.

```mermaid
sequenceDiagram
  autonumber
  actor Client as End user
  participant Widget as Chat-Widget (A)
  participant RuuterA as Ruuter public (A)
  participant AgentA as DMR agent (A)
  participant Server as DMR server
  participant GC as Global-Classifier
  participant AgentB as DMR agent (B)
  participant BykB as Bürokratt B

  Client->>Widget: Question
  Widget->>RuuterA: Question
  Note over RuuterA: Bürokratt A has no answer
  RuuterA->>AgentA: Question
  AgentA->>Server: Signed and encrypted question (WebSocket)
  Note over Server: Cannot read the content
  Server->>GC: Question, through the classifier's own DMR agent
  GC-->>Server: Matching agency
  Server-->>AgentA: Matching agency
  AgentA-->>RuuterA: Agency B can answer
  RuuterA-->>Widget: Event: agency B can answer this. Redirect?
  Widget-->>Client: Redirect to agency B?

  alt User agrees
    Client->>Widget: Yes
    Widget->>RuuterA: Redirect
    RuuterA->>AgentA: Question for agency B
    AgentA->>Server: Signed and encrypted question
    Server->>AgentB: Question
    AgentB->>BykB: Decrypted question
    BykB-->>AgentB: Answer
    AgentB-->>Server: Signed and encrypted answer
    Server-->>AgentA: Answer
    AgentA-->>RuuterA: Answer
    RuuterA-->>Widget: Answer
  else User declines
    Client->>Widget: No
    Note over Widget,RuuterA: The conversation stays with Bürokratt A
  end
```

The DMR server routes through RabbitMQ and gets the list of network members from CentOps.

## 3. How the Global-Classifier gets its data

The classifier learns each agency's topics from that agency's knowledge base (CKB). CKB data never travels through the DMR or CentOps; only the download link and the checksum do.

```mermaid
sequenceDiagram
  autonumber
  participant CKB as CKB (each agency)
  participant S3 as S3 storage (agency, SeaweedFS)
  participant CentOps
  participant GC as Global-Classifier

  loop Every hour, in each CKB
    CKB->>CKB: Has the data checksum changed? Has the previous link expired?
    opt Either is true
      CKB->>S3: Store a new zip, get a presigned link
      CKB->>CentOps: Link + checksum (CKB's own API key)
    end
  end

  loop Every hour, in the Global-Classifier
    GC->>CentOps: Get all CKBs (classifier's API key)
    CentOps-->>GC: Links + checksums
    opt A checksum has changed
      GC->>S3: Download the zip with its link (HTTPS)
      GC->>GC: Build one dataset for all agencies
    end
  end

  Note over GC: An administrator starts training a new model
```

Downloading the zip is the classifier's only connection into an agency's storage. An agency that fails does not stop the others. CentOps lets each CKB update only its own entry.
