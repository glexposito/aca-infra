# aca-infra

Terragrunt/Terraform scaffold for deploying a containerized personal app to Azure Container Apps.

> [!WARNING]
> This repository is a proof of concept.
> It is intended for experimentation and learning in a disposable Azure account, not as a hardened production baseline.
> Expect breaking refactors, manual resets, and destructive rebuilds while the structure is still being explored.

This repository implements the [Gruntwork Terragrunt Reference Architecture](docs/terragrunt-architecture.md), utilizing a strict hierarchical layout (`subscription/region/environment/service`) to maximize configuration reuse (DRY) and strictly limit the blast radius of changes.

## Architecture & Layout

- `modules/aca-environment`: Reusable Terraform module for the shared foundation (Resource Group, Log Analytics, Container App Environment).
- `modules/aca-app`: Reusable Terraform module for deploying specific microservices into an existing `aca-environment`.
- `live/`: The "Live" infrastructure configurations, organized by hierarchy:

```text
live/
├── _catalog/
│   ├── units/
│   │   ├── app-env/
│   │   └── myapp/
│   └── stacks/
│       └── master.stack.hcl
├── non-prod/
│   └── australiaeast/
│       ├── dev/
│       │   └── terragrunt.stack.hcl
│       └── stg/
│           └── terragrunt.stack.hcl
└── prod/
    ├── australiaeast/
    │   └── prod/
    │       └── terragrunt.stack.hcl
    └── southeastasia/
        └── prod/
            └── terragrunt.stack.hcl
```

### Documentation
For detailed information on how to work with this architecture, see the following guides:
- 📖 [**Terraform & Terragrunt Concepts**](docs/terraform-terragrunt-concepts.md): Foundations of IaC and how they are implemented in this repository.
- 📖 [**Terragrunt Architecture Guide**](docs/terragrunt-architecture.md): How to add new regions, manage inheritance, and safely decommission environments.
- 📖 [**GitHub Actions & Azure Setup**](docs/azure-github-actions-setup.md): Guide for bootstrapping the Azure OIDC connection and State storage.

---

## Naming Convention

Azure naming conventions are generated dynamically from the shared stack token, app token, environment, and region shortcode:

- Shared environment resource group: `rg-<shared-stack>-<env>-<region>`
- Shared Container Apps environment: `cae-<shared-stack>-<env>-<region>`
- Shared Log Analytics workspace: `law-<shared-stack>-<env>-<region>`
- Application Container App: `ca-<app>-<env>-<region>`

*Current app token: `myapp`. Current shared environment stack token: `core`. Current region shortcodes: `aue` for Australia East and `sea` for Southeast Asia.*

## Terragrunt Stacks & Unit Catalog

This repository uses **Terragrunt Stacks** to orchestrate infrastructure. Instead of having a `terragrunt.hcl` file for every single resource in every environment, we define a single `terragrunt.stack.hcl` file in each environment root.

- **`live/_catalog/units/`**: Contains generic unit definitions (`terragrunt.hcl`).
- **`live/_catalog/stacks/master.stack.hcl`**: A master blueprint that defines all units and how they relate. Units are enabled by default.
- **`terragrunt.stack.hcl`**: Found in each environment folder. It includes the master blueprint. To "choose" which units to deploy, you can override specific units.

Example `terragrunt.stack.hcl` (Southeast Asia - Platform Only):
```hcl
include "master" {
  path = "${get_repo_root()}/live/_catalog/stacks/master.stack.hcl"
}

# Choose only the platform by disabling the app unit
unit "myapp" {
  enabled = false
}
```

## Required Environment Variables

To run Terragrunt locally, you need the following Azure authentication and state variables:

- `AZURE_SUBSCRIPTION_ID`
- `AZURE_TENANT_ID`
- `TG_STATE_RESOURCE_GROUP`
- `TG_STATE_STORAGE_ACCOUNT`
- `TG_STATE_CONTAINER`

## Workload-Specific Environment Variables

- `MYAPP_IMAGE`
- `MYAPP_REGISTRY_SERVER` (optional)
- `MYAPP_ACR_ID` (optional)
- `STATUSPAGE_API_KEY`

## Example Usage

To deploy an entire environment, run from the environment root:

```bash
cd live/non-prod/australiaeast/dev
terragrunt stack run init
terragrunt stack run plan
terragrunt stack run apply
```

## GitHub Actions CI/CD

The workflow is located in [`.github/workflows/provision-myapp-infra.yml`](.github/workflows/provision-myapp-infra.yml).
