# Contributing to Azazel

## Before you start

This is the doctrine hub: README.md and `docs/specs/naming.md` are canonical for the whole Azazel series. Read them first.

## Branch naming

`<type>/<short-description>`

Examples: `docs/products-index-refresh`, `naming/az-06-designation`, `site/nav-cleanup`

## Commit message format

`<type>(<scope>): <summary>`

- type: `docs` / `fix` / `chore`
- scope: `docs` / `naming` / `products` / `philosophy` / `concepts` / `site`

## Pull request rules

- 1 PR = 1 purpose. Do not mix unrelated changes.
- Every PR must include:
  - [ ] All internal links resolve (no broken relative paths)
  - [ ] `_config.yml` nav updated if a page moved or was added/removed
  - [ ] `docs/index_ja.md` updated when `docs/index.md` changes (JA mirror stays in sync)
  - [ ] Naming-spec compliance: no new Form/Role word without updating `docs/specs/naming.md` first; no restricted terms (e.g. "Jamming")

## What not to do (requires owner sign-off)

- Do not change the naming spec (`docs/specs/naming.md`), the License Matrix, or any `AZ-xx` designation without owner sign-off.
- Do not add product code here. Product implementation belongs in the product repositories (Azazel-Edge, Azazel-Gadget, Azazel-Knowledge, Azazel-Fabric).

## License

Contributions are accepted under Apache-2.0, the license of this repository.
