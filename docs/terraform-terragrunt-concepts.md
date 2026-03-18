# Terraform & Terragrunt Concepts in ACA-Infra

This document explains the foundational concepts of Terraform and Terragrunt as they are applied in this repository.

---

## 1. Terraform Basics

Terraform is an Infrastructure as Code (IaC) tool.
- **Providers**: Plugins to interact with cloud providers (like Azure).
- **Modules**: Containers for multiple resources (like `aca-app`).
- **State**: The record of your managed infrastructure.

---

## 2. Terragrunt Concepts

Terragrunt provides extra tools for keeping your configurations DRY and managing stacks.

### Terragrunt Stacks & Units
A **Stack** is a collection of related infrastructure **Units**.
- **Units**: The individual components (e.g., `app-env`, `myapp`).
- **Master Stack (`live/_catalog/stacks/master.stack.hcl`)**: A central blueprint that defines all units and their relationships.
- **Native Selection**: Terragrunt Stacks merge unit blocks by name. To customize a stack for a specific environment, you include the master blueprint and then redefine specific units with `enabled = false` to disable them.

### Dependencies
- **Outputs to Inputs**: Terragrunt automatically takes the `outputs` from one unit and passes them as `values` to another unit within the stack. You reference them directly: `unit.app_env.outputs.id`.

### Remote State Management
Terragrunt automatically configures the remote state for each unit based on its path. By using `no_dot_terragrunt_stack = true`, state paths are maintained exactly as they were in the traditional folder structure.

---

## 3. How they work together in this Repo

The folder structure provides the context for the Stack:
1.  **Subscription Layer** (`live/non-prod/subscription.hcl`)
2.  **Region Layer** (`live/non-prod/australiaeast/region.hcl`)
3.  **Environment Layer** (`live/non-prod/australiaeast/dev/env.hcl`)
4.  **Stack Layer** (`live/non-prod/australiaeast/dev/terragrunt.stack.hcl`): Orchestrates the deployment by including the master blueprint and overriding units as needed.

### Deployment Flow
1.  Terragrunt reads the `terragrunt.stack.hcl`.
2.  It resolves the Master Stack and any block overrides (e.g., `enabled = false`).
3.  It generates individual `terragrunt.hcl` files for each enabled unit.
4.  It runs `terraform apply` for each enabled unit in the correct order.
