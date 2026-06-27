## ADDED Requirements

### Requirement: openspec README orients without duplicating upstream docs
The `openspec/README.md` SHALL explain the directory structure and point to the OpenSpec CLI for workflow details, rather than documenting the workflow itself.

#### Scenario: New contributor reads the README
- **WHEN** a contributor opens `openspec/README.md`
- **THEN** they understand what the `openspec/` directory contains and how it is structured
- **THEN** they are directed to use the OpenSpec CLI (`/opsx:propose`, `/opsx:explore`) rather than a manual template workflow
- **THEN** they can locate the baseline snapshot and understand its role

#### Scenario: README does not duplicate OpenSpec tool documentation
- **WHEN** `openspec/README.md` is compared to the OpenSpec upstream docs
- **THEN** it contains no workflow instructions that are already covered by the CLI
- **THEN** it is under 40 lines
