# Delivery pipeline

How Bürokratt software reaches the clusters where installations run. Component names match the [overview diagram](README.md#overview).

This design was agreed on 2026-10-19 and is being built. It replaces delivery with `helm install` from local machines; the target clusters run RKE2.

- [Overview](#overview)
- [Components](#components)
- [How the pipeline runs](#how-the-pipeline-runs)

## Overview

![Bürokratt delivery pipeline](img/delivery.drawio.svg)

**Management cluster.** Runs only the main Argo CD. It installs the central stack `central-<environment>` into every environment cluster from configuration in GitLab. It does not deploy installations.

**Environment clusters.** Test, stage and prod, each an RKE2 cluster. Every cluster has its own central stack (`central-test`, `central-stage`, `central-prod`). Each installation runs in its own namespace; the stage cluster has 14 (`byk-01` … `byk-14`).

**Isolation.** The local Argo CD takes instructions only from the CentOps in the same cluster and deploys only to that cluster (destination `in-cluster`). The test environment knows nothing about the prod cluster or its central stack. If the management cluster or one environment fails, the other environments keep running and keep deploying.

**Rejected alternatives.** Everything in the management cluster; or the central stacks in the management cluster with one shared CentOps and Argo CD. Both make the management cluster a single point of failure for every environment.

### Editing the diagram

`img/delivery.drawio.svg` is both the picture and its source; edit it in [draw.io](https://app.diagrams.net) as described in the [overview](README.md#editing-the-diagram).

## Components

| Component | Where | Role |
|---|---|---|
| GitLab | External | Helm charts of Bürokratt and the configuration of the central stack |
| Main Argo CD | Management cluster | Installs and updates the central stack in each environment cluster |
| CentOps | `central-<env>` | Tells the local Argo CD which installations to deploy, with which chart and values |
| Local Argo CD | `central-<env>` | Renders the chart from GitLab and deploys it to the installation's namespace in the same cluster |
| Vault | `central-<env>` | Secrets of installations; read during rendering by argocd-vault-plugin |
| Bükstack | `central-<env>` | Ruuter, Resql and TIM of the central stack |
| PostgreSQL | `central-<env>` | Central database of the central stack |
| DMR | `central-<env>` | DMR server for the installations of this environment |
| OpenSearch | `central-<env>` | Search and logs for this environment |
| Installation | `byk-NN` | One Bürokratt installation as described in the [overview](README.md#client-installation) |

The CentOps endpoints the pipeline needs run in the central stack, on its Bükstack components and central database.

## How the pipeline runs

Delivery happens on two levels: the main Argo CD delivers the central stack, and in each cluster the local Argo CD delivers installations.

### 1. Central stack

```mermaid
sequenceDiagram
  autonumber
  participant GitLab
  participant Main as Main Argo CD (management cluster)
  participant Central as central-<env> (each environment cluster)

  Main->>GitLab: Read central stack configuration
  Note over Main: ApplicationSet creates one Application per environment cluster
  Main->>Central: Sync Vault, Bükstack, PostgreSQL, CentOps, local Argo CD, DMR, OpenSearch
```

1. The configuration of the central stack is kept in GitLab.
2. An ApplicationSet in the main Argo CD generates one Application per environment cluster, with `central-<env>` as the destination namespace.
3. The main Argo CD syncs each Application into its cluster. A change in GitLab reaches the clusters through the same sync.

### 2. Installations

```mermaid
sequenceDiagram
  autonumber
  actor Op as Operator
  participant CentOps as CentOps (central-stage)
  participant Vault as Vault (central-stage)
  participant Argo as Argo CD (central-stage)
  participant GitLab
  participant NS as byk-01

  Op->>CentOps: Installation: namespace, chart, branch, Helm values, secrets
  CentOps->>Vault: Store secrets
  Op->>CentOps: Deploy
  CentOps->>Argo: Create or update the Application (Argo CD API)
  Argo->>GitLab: Fetch chart at branch
  Argo->>Vault: argocd-vault-plugin replaces placeholders with secret values
  Argo->>NS: Sync (in-cluster)
  CentOps->>Argo: Read health and sync status
```

1. The Helm charts of Bürokratt are kept in GitLab.
2. In the CentOps of the target cluster, an operator describes the installation: namespace, chart repository, path and branch, and the Helm values. Secrets go to Vault; the Helm values refer to them only as argocd-vault-plugin placeholders, so no secret value is stored in git or in CentOps.
3. On Deploy, CentOps creates or updates one Argo CD Application for the installation in the local Argo CD.
4. The local Argo CD fetches the chart from GitLab, argocd-vault-plugin fills in the secrets from Vault, and the chart is rendered.
5. The local Argo CD applies the result to the installation's namespace in the same cluster. Sync is automated with prune and self-heal, so the namespace keeps matching what was rendered, and new commits on the chart branch are deployed without another Deploy.
6. CentOps reads health and sync status back from the local Argo CD and shows it to the operator.

A new version reaches an environment when its CentOps points the installation at a new chart branch or new values and deploys again. Each environment is deployed from its own CentOps; nothing is pushed from one environment to another.
