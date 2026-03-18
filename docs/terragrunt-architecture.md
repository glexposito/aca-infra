# Terragrunt Reference Architecture

This repository uses the Gruntwork "Live" Infrastructure Pattern (also known as the Terragrunt Reference Architecture) to manage Azure infrastructure deployments. 

> **Reference:** This approach is heavily inspired by the official Gruntwork examples, specifically the [terragrunt-infrastructure-live-stacks-example](https://github.com/gruntwork-io/terragrunt-infrastructure-live-stacks-example) repository.

This pattern relies on a strict directory hierarchy to keep configuration DRY (Don't Repeat Yourself), strictly limit the blast radius of changes, and provide a clear, discoverable map of your cloud environments.

## Directory Structure Hierarchy

The `live/` directory is organized into the following hierarchy:

```text
live/
├── _catalog/
│   ├── units/
│   │   ├── app-env/
│   │   └── myapp/
│   └── stacks/
│       └── master.stack.hcl
└── [subscription] / [region] / [environment] / terragrunt.stack.hcl
```

*   **Subscription (`live/non-prod/`, `live/prod/`):** Represents the Azure Subscription boundary. This provides the highest level of isolation for security and billing. Contains a `subscription.hcl` file.
*   **Region (`australiaeast/`):** Represents the physical Azure region where resources are deployed. Contains a `region.hcl` file.
*   **Environment (`dev/`, `stg/`, `prod/`):** The logical deployment stage. Contains an `env.hcl` file.
*   **Stack Definition (`terragrunt.stack.hcl`):** The final "leaf" that orchestrates the deployment of all units by including the master blueprint and overriding units as needed.
*   **Catalog (`live/_catalog/`):** Centralized blueprints and orchestration logic.

### Example Layout

```text
live/
├── _catalog/
│   ├── units/                   # Generic blueprints for units
│   └── stacks/
│       └── master.stack.hcl     # The master orchestration logic
├── non-prod/
│   ├── subscription.hcl         # Defines subscription_name = "non-prod"
│   └── australiaeast/
│       ├── region.hcl           # Defines location = "australiaeast"
│       ├── dev/
│       │   ├── env.hcl          # Defines environment = "dev"
│       │   └── terragrunt.stack.hcl # Includes master (Both units enabled)
└── prod/
    └── southeastasia/
        └── prod/
            ├── env.hcl          # Defines environment = "prod"
            └── terragrunt.stack.hcl # Includes master & disables myapp
```

## How It Works

1.  **Terragrunt Stacks:** We use `terragrunt.stack.hcl` to orchestrate multiple units as a single logical stack.
2.  **Master Blueprint:** All units are defined once in `live/_catalog/stacks/master.stack.hcl`. Units are enabled by default.
3.  **Block Overriding:** Terragrunt Stacks merge blocks by name. To "choose" units in a specific environment, you include the master stack and then simply set `enabled = false` for the units you don't want.
4.  **Clean References:** Dependencies between units are handled natively in the master blueprint. You reference unit outputs directly (e.g., `unit.app_env.outputs.id`).

## How to Extend the Architecture

### Scenario: Adding a New Unit (e.g., a Database)

1.  Create the unit in `live/_catalog/units/my-db/`.
2.  Add a `unit "my_db"` block to `live/_catalog/stacks/master.stack.hcl`.
3.  The unit is now available in all environments. Disable it where not needed.

---

## How to Decommission an Environment (or Region)

Navigate into the environment root and destroy the stack.

```bash
cd live/prod/southeastasia/prod
terragrunt stack run destroy -- -auto-approve -no-color
```
