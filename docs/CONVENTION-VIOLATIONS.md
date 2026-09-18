# Git Convention Violations - `PAD-team1` and submodules

> **Status: remediated for `PAD-team1`.** This report records the state of the repository
> *before* the cleanup. It is kept as the audit trail. What has since been fixed:
>
> - `main` and `dev` were rebuilt as a linear, 26-commit Conventional-Commit history with every
>   contributor's original authorship and dates preserved; all 7 merge commits and all 21
>   duplicated commits are gone. The file tree is byte-identical to the pre-cleanup `main`.
> - All 30 pull request titles were rewritten to Conventional Commits; all 16 empty PR
>   descriptions were filled in.
> - `.github/pull_request_template.md`, `.github/CODEOWNERS`, and the `Conventions` and `CI`
>   workflows were added, so branch names, PR titles, PR descriptions and base branches are now
>   enforced automatically.
> - The README's `development`/`dev` contradiction and its two mojibake artefacts are fixed.
> - The repository is now squash-merge-only with auto-delete of merged branches, and the `main`
>   ruleset requires linear history.
>
> Still open, deliberately: the 22 pull requests with no related-issue reference. Back-filling
> them would mean creating issues today and linking them to PRs merged in September, which
> would be fabricated history rather than a fix. The rule is now enforced for all future PRs.
> The branch-naming violations are likewise historical facts recorded in the PR list and cannot
> be rewritten.

A full audit of every branch, commit and pull request in `DimonBel/PAD-team1`,
`DimonBel/player-service` and `DimonBel/game-service`, checked against the conventions
declared in the repository README (Branch Structure, Branch Naming Convention, Branch Types,
Merging Strategy, Code Review Guidelines, Workflow Summary, Conventional Commits).

| | |
|---|---|
| Repositories audited | 3 (`PAD-team1`, `player-service`, `game-service`) |
| Commits scanned | 62 (54 in `PAD-team1`, 4 in `player-service`, 4 in `game-service`) |
| Pull requests scanned | 32 (30 + 1 + 1), all merged except PR #10 (closed) |
| Branches scanned | 26 distinct branch names |
| **Total violations** | **152** |

> The six remaining submodules (`resource-service`, `zombie-service`, `base-service`,
> `crafting-service`, `world-service`, `exam-service`) are owned by other accounts and are
> not readable with the current credentials, so they are out of scope here. Their working
> trees in this checkout are empty (submodules not initialised).

## Summary by category

| Category | Violations |
|---|---:|
| Branch naming | 19 |
| Commit messages | 38 |
| Commit history | 7 |
| Branching workflow | 10 |
| Review policy | 7 |
| PR hygiene | 55 |
| Process | 16 |
| **Total** | **152** |

## Summary by rule

| Rule | Category | What the convention says is wrong | Count |
|---|---|---|---:|
| `B1` | Branch naming | Branch is not `type/service-name/FeatureName` (wrong number of segments) | 9 |
| `B2` | Branch naming | Branch type is not one of feat/fix/hotfix/refactor/docs/chore/test | 5 |
| `B3` | Branch naming | Branch type segment is not lowercase | 1 |
| `B4` | Branch naming | Middle segment is not a microservice name or `shared` | 4 |
| `C1` | Commit history | Merge commit present although the strategy is squash-and-merge only | 7 |
| `C2` | Commit messages | Commit subject is not a Conventional Commit (`type(scope): subject`) | 32 |
| `C4` | Commit messages | Leading/trailing whitespace in the commit subject | 2 |
| `C5` | Commit messages | Mojibake / corrupted characters in the commit subject | 4 |
| `P1` | Review policy | PR merged with 0 reviews (README requires 1 approving reviewer) | 7 |
| `P2` | PR hygiene | PR description is empty - PR template not followed | 18 |
| `P3` | PR hygiene | PR description has no related-issue reference | 13 |
| `P4` | Branching workflow | Feature branch opened directly against `main` instead of `dev` | 8 |
| `P5` | Branching workflow | Targets `development` while the rest of the repo targets `dev` | 2 |
| `P6` | PR hygiene | PR title is the auto-generated branch name, not a Conventional Commit | 19 |
| `P7` | PR hygiene | Leading/trailing whitespace in the PR title | 2 |
| `P8` | PR hygiene | Mojibake / corrupted characters in the PR title | 2 |
| `P9` | PR hygiene | Truncated PR title ending in an ellipsis | 1 |
| `R1` | Process | Workflow step 1 ("Create Issue") never followed - repo has 0 issues | 3 |
| `R2` | Process | No `.github/` directory - PR template referenced by the README does not exist | 3 |
| `R3` | Process | README contradicts itself on the integration branch name | 1 |
| `R4` | Process | Documented branch does not exist on the remote | 1 |
| `R5` | Process | Merged branch never deleted | 2 |
| `R6` | Process | Stale unmerged branch pushed without a PR | 2 |
| `R7` | Process | Private/local branch merged into `main` with no PR and no review | 1 |
| `R8` | Process | `main` history is not clean/linear - duplicated commits | 1 |
| `R9` | Process | No CI, although the README requires all PRs to pass automated tests | 1 |
| `R10` | Process | Inconsistent committer identities | 1 |

## Summary by repository

| Repository | Violations |
|---|---:|
| `PAD-team1` | 128 |
| `player-service` | 12 |
| `game-service` | 12 |

---

# Full violation list

## Branch naming (19)

| # | Rule | Repository | Object | Violation |
|---:|---|---|---|---|
| 1 | `B4` | `PAD-team1` | `feat/doc/UpdateREADME` | Middle segment `doc` is not a service name or `shared` (PR #1) |
| 2 | `B1` | `PAD-team1` | `chore/SubmoduleSetup` | Not `type/service-name/FeatureName` — has 2 segment(s), expected 3 (PR #3) |
| 3 | `B1` | `PAD-team1` | `docs/UpdateReadme` | Not `type/service-name/FeatureName` — has 2 segment(s), expected 3 (PR #4) |
| 4 | `B4` | `PAD-team1` | `chore/doc/UpdateCommunication` | Middle segment `doc` is not a service name or `shared` (PR #7) |
| 5 | `B1` | `PAD-team1` | `chore/TestBranchRuleset` | Not `type/service-name/FeatureName` — has 2 segment(s), expected 3 (PR #12) |
| 6 | `B4` | `PAD-team1` | `docs/endpoints/DmitriiService` | Middle segment `endpoints` is not a service name or `shared` (PR #16) |
| 7 | `B2` | `PAD-team1` | `doc/readme/Arhitecture` | Invalid branch type `doc/` — allowed: feat, fix, hotfix, refactor, docs, chore, test (PR #23) |
| 8 | `B4` | `PAD-team1` | `doc/readme/Arhitecture` | Middle segment `readme` is not a service name or `shared` (PR #23) |
| 9 | `B1` | `PAD-team1` | `chore/UpdateServiceReferences` | Not `type/service-name/FeatureName` — has 2 segment(s), expected 3 (PR #25) |
| 10 | `B1` | `PAD-team1` | `docs/base-crafting-readme` | Not `type/service-name/FeatureName` — has 2 segment(s), expected 3 (PR #27) |
| 11 | `B1` | `PAD-team1` | `DimonBel-patch-1` | Not `type/service-name/FeatureName` — has 1 segment(s), expected 3 (PR #29) |
| 12 | `B2` | `PAD-team1` | `DimonBel-patch-1` | Invalid branch type `DimonBel-patch-1/` — allowed: feat, fix, hotfix, refactor, docs, chore, test (PR #29) |
| 13 | `B3` | `PAD-team1` | `DimonBel-patch-1` | Branch type segment `DimonBel-patch-1` is not lowercase (PR #29) |
| 14 | `B1` | `PAD-team1` | `private/game-service-submodule` | Not `type/service-name/FeatureName` — has 2 segment(s), expected 3 (merged b9e5a7c/ec7edc6) |
| 15 | `B2` | `PAD-team1` | `private/game-service-submodule` | Invalid branch type `private/` — allowed: feat, fix, hotfix, refactor, docs, chore, test (merged b9e5a7c/ec7edc6) |
| 16 | `B1` | `player-service` | `doc/update` | Not `type/service-name/FeatureName` — has 2 segment(s), expected 3 (live branch) |
| 17 | `B2` | `player-service` | `doc/update` | Invalid branch type `doc/` — allowed: feat, fix, hotfix, refactor, docs, chore, test (live branch) |
| 18 | `B1` | `game-service` | `doc/update` | Not `type/service-name/FeatureName` — has 2 segment(s), expected 3 (live branch) |
| 19 | `B2` | `game-service` | `doc/update` | Invalid branch type `doc/` — allowed: feat, fix, hotfix, refactor, docs, chore, test (live branch) |

## Commit messages (38)

| # | Rule | Repository | Object | Violation |
|---:|---|---|---|---|
| 20 | `C2` | `PAD-team1` | `18788ee` | Not a Conventional Commit (`type(scope): subject`): "Revise README for branch guidelines and remove old content" |
| 21 | `C5` | `PAD-team1` | `1e43df2` | Mojibake / non-ASCII garbage in subject: "chore: test new branch ruleset в† (#12) (#13)" |
| 22 | `C5` | `PAD-team1` | `204ebe1` | Mojibake / non-ASCII garbage in subject: "chore: test new branch ruleset в† (#12)" |
| 23 | `C2` | `PAD-team1` | `23f8bfc` | Not a Conventional Commit (`type(scope): subject`): "Docs/endpoints/dmitrii service (#16)" |
| 24 | `C2` | `PAD-team1` | `2bf7119` | Not a Conventional Commit (`type(scope): subject`): " chore/shared/add world exam submodules (#9) #10 (#11)" |
| 25 | `C4` | `PAD-team1` | `2bf7119` | Leading/trailing whitespace in subject: " chore/shared/add world exam submodules (#9) #10 (#11)" |
| 26 | `C5` | `PAD-team1` | `321ba39` | Mojibake / non-ASCII garbage in subject: "chore: test new branch ruleset в† (#12) (#13)" |
| 27 | `C2` | `PAD-team1` | `339be2e` | Not a Conventional Commit (`type(scope): subject`): "Dev  (#20)" |
| 28 | `C5` | `PAD-team1` | `41bce0a` | Mojibake / non-ASCII garbage in subject: "chore: test new branch ruleset в† (#12)" |
| 29 | `C2` | `PAD-team1` | `4556a4e` | Not a Conventional Commit (`type(scope): subject`): "Docs/endpoints/dmitrii service (#16)" |
| 30 | `C2` | `PAD-team1` | `49970f7` | Not a Conventional Commit (`type(scope): subject`): "Chore/update service references (#25)" |
| 31 | `C2` | `PAD-team1` | `55282da` | Not a Conventional Commit (`type(scope): subject`): "Dev (#22)" |
| 32 | `C2` | `PAD-team1` | `6116d2e` | Not a Conventional Commit (`type(scope): subject`): " chore/shared/add world exam submodules (#9) #10 (#11)" |
| 33 | `C4` | `PAD-team1` | `6116d2e` | Leading/trailing whitespace in subject: " chore/shared/add world exam submodules (#9) #10 (#11)" |
| 34 | `C2` | `PAD-team1` | `617f587` | Not a Conventional Commit (`type(scope): subject`): "Chore/shared/update private readme (#21)" |
| 35 | `C2` | `PAD-team1` | `694ef9d` | Not a Conventional Commit (`type(scope): subject`): "doc: update arhitecture diagram (#23)" |
| 36 | `C2` | `PAD-team1` | `757d1e3` | Not a Conventional Commit (`type(scope): subject`): "Dev (#15)" |
| 37 | `C2` | `PAD-team1` | `8c155ec` | Not a Conventional Commit (`type(scope): subject`): "Docs/shared/add endpoints service boundaries (#14)" |
| 38 | `C2` | `PAD-team1` | `8e14e58` | Not a Conventional Commit (`type(scope): subject`): "first commit" |
| 39 | `C2` | `PAD-team1` | `9bb060f` | Not a Conventional Commit (`type(scope): subject`): "Dev update (#28)" |
| 40 | `C2` | `PAD-team1` | `9bd1c13` | Not a Conventional Commit (`type(scope): subject`): "Docs/contracts/update service endpoints (#17)" |
| 41 | `C2` | `PAD-team1` | `b29b029` | Not a Conventional Commit (`type(scope): subject`): "Feat/shared/update submodules (#26)" |
| 42 | `C2` | `PAD-team1` | `b37bdf0` | Not a Conventional Commit (`type(scope): subject`): "Dev Changes Endpoints (#18)" |
| 44 | `C2` | `PAD-team1` | `b60ef75` | Not a Conventional Commit (`type(scope): subject`): "Docs/shared/add endpoints service boundaries (#14)" |
| 46 | `C2` | `PAD-team1` | `cb00559` | Not a Conventional Commit (`type(scope): subject`): "Dev Changes Endpoints (#18)" |
| 47 | `C2` | `PAD-team1` | `cced9ec` | Not a Conventional Commit (`type(scope): subject`): "Dev (#15)" |
| 49 | `C2` | `PAD-team1` | `ce1adfa` | Not a Conventional Commit (`type(scope): subject`): "doc: update arhitecture diagram (#23) (#24)" |
| 50 | `C2` | `PAD-team1` | `d128653` | Not a Conventional Commit (`type(scope): subject`): "Revise branch names and clean up PR template section (#29)" |
| 51 | `C2` | `PAD-team1` | `da1e963` | Not a Conventional Commit (`type(scope): subject`): "doc: update arhitecture diagram (#23)" |
| 52 | `C2` | `PAD-team1` | `dd6de95` | Not a Conventional Commit (`type(scope): subject`): "Docs/shared/update readme (#2)" |
| 53 | `C2` | `PAD-team1` | `df6b316` | Not a Conventional Commit (`type(scope): subject`): "Docs/shared/update readme (#2)" |
| 54 | `C2` | `PAD-team1` | `e198442` | Not a Conventional Commit (`type(scope): subject`): "Dev (#30)" |
| 56 | `C2` | `PAD-team1` | `ebde6a2` | Not a Conventional Commit (`type(scope): subject`): "Docs/contracts/update service endpoints (#17)" |
| 58 | `C2` | `PAD-team1` | `f5e437d` | Not a Conventional Commit (`type(scope): subject`): "Chore/shared/update private readme (#21)" |
| 60 | `C2` | `player-service` | `ecc579d` | Not a Conventional Commit (`type(scope): subject`): "Initial commit" |
| 61 | `C2` | `player-service` | `29bb1b2` | Not a Conventional Commit (`type(scope): subject`): "doc:update the readme file for player service" |
| 63 | `C2` | `game-service` | `08aa1f4` | Not a Conventional Commit (`type(scope): subject`): "Initial commit" |
| 64 | `C2` | `game-service` | `9151ff2` | Not a Conventional Commit (`type(scope): subject`): "doc: update readme for game service" |

## Commit history (7)

| # | Rule | Repository | Object | Violation |
|---:|---|---|---|---|
| 43 | `C1` | `PAD-team1` | `b4f15af` | Merge commit on a squash-merge-only workflow: "Merge branch 'main' into dev" |
| 45 | `C1` | `PAD-team1` | `b9e5a7c` | Merge commit on a squash-merge-only workflow: "Merge branch 'private/game-service-submodule' into main" |
| 48 | `C1` | `PAD-team1` | `cd00c44` | Merge commit on a squash-merge-only workflow: "Merge branch 'main' into dev" |
| 55 | `C1` | `PAD-team1` | `e5c0ca9` | Merge commit on a squash-merge-only workflow: "Merge remote-tracking branch 'origin/main' into dev" |
| 57 | `C1` | `PAD-team1` | `ec7edc6` | Merge commit on a squash-merge-only workflow: "Merge branch 'private/game-service-submodule' into main" |
| 59 | `C1` | `player-service` | `dd2e208` | Merge commit on a squash-merge-only workflow: "Merge pull request #1 from DimonBel/docs/player-service/AddReadme" |
| 62 | `C1` | `game-service` | `d514a05` | Merge commit on a squash-merge-only workflow: "Merge pull request #1 from DimonBel/docs/game-service/AddReadme" |

## Branching workflow (10)

| # | Rule | Repository | Object | Violation |
|---:|---|---|---|---|
| 67 | `P4` | `PAD-team1` | `PR #1` | Feature branch `feat/doc/UpdateREADME` opened directly against `main`; the workflow requires branching from and merging into `dev` |
| 71 | `P4` | `PAD-team1` | `PR #2` | Feature branch `docs/shared/UpdateReadme` opened directly against `main`; the workflow requires branching from and merging into `dev` |
| 75 | `P4` | `PAD-team1` | `PR #3` | Feature branch `chore/SubmoduleSetup` opened directly against `main`; the workflow requires branching from and merging into `dev` |
| 77 | `P4` | `PAD-team1` | `PR #4` | Feature branch `docs/UpdateReadme` opened directly against `main`; the workflow requires branching from and merging into `dev` |
| 80 | `P5` | `PAD-team1` | `PR #5` | Targets `development` while the rest of the repo targets `dev` - the two integration branch names were used interchangeably |
| 83 | `P4` | `PAD-team1` | `PR #7` | Feature branch `chore/doc/UpdateCommunication` opened directly against `main`; the workflow requires branching from and merging into `dev` |
| 85 | `P4` | `PAD-team1` | `PR #8` | Feature branch `docs/contracts/AddServiceEndpoints` opened directly against `main`; the workflow requires branching from and merging into `dev` |
| 88 | `P5` | `PAD-team1` | `PR #9` | Targets `development` while the rest of the repo targets `dev` - the two integration branch names were used interchangeably |
| 133 | `P4` | `player-service` | `PR #1` | Feature branch `docs/player-service/AddReadme` opened directly against `main`; the workflow requires branching from and merging into `dev` |
| 136 | `P4` | `game-service` | `PR #1` | Feature branch `docs/game-service/AddReadme` opened directly against `main`; the workflow requires branching from and merging into `dev` |

## Review policy (7)

| # | Rule | Repository | Object | Violation |
|---:|---|---|---|---|
| 65 | `P1` | `PAD-team1` | `PR #1` | Merged with 0 reviews - README requires at least 1 approving reviewer (author DimonBel, `feat/doc/UpdateREADME` -> `main`) |
| 69 | `P1` | `PAD-team1` | `PR #2` | Merged with 0 reviews - README requires at least 1 approving reviewer (author DimonBel, `docs/shared/UpdateReadme` -> `main`) |
| 73 | `P1` | `PAD-team1` | `PR #3` | Merged with 0 reviews - README requires at least 1 approving reviewer (author tukaram40k, `chore/SubmoduleSetup` -> `main`) |
| 78 | `P1` | `PAD-team1` | `PR #5` | Merged with 0 reviews - README requires at least 1 approving reviewer (author AlexandraB-C, `chore/shared/AddBaseCraftingSubmodules` -> `development`) |
| 86 | `P1` | `PAD-team1` | `PR #9` | Merged with 0 reviews - README requires at least 1 approving reviewer (author danganhuh, `chore/shared/AddWorldExamSubmodules` -> `development`) |
| 131 | `P1` | `player-service` | `PR #1` | Merged with 0 reviews - README requires at least 1 approving reviewer (author DimonBel, `docs/player-service/AddReadme` -> `main`) |
| 134 | `P1` | `game-service` | `PR #1` | Merged with 0 reviews - README requires at least 1 approving reviewer (author DimonBel, `docs/game-service/AddReadme` -> `main`) |

## PR hygiene (55)

| # | Rule | Repository | Object | Violation |
|---:|---|---|---|---|
| 66 | `P3` | `PAD-team1` | `PR #1` | PR description contains no related-issue reference (`#N`), which the README requires (title: "feat: complite Technologies & Communication Patterns, branch structur…") |
| 68 | `P9` | `PAD-team1` | `PR #1` | Truncated PR title ending in an ellipsis: "feat: complite Technologies & Communication Patterns, branch structur…" |
| 70 | `P3` | `PAD-team1` | `PR #2` | PR description contains no related-issue reference (`#N`), which the README requires (title: "Docs/shared/update readme") |
| 72 | `P6` | `PAD-team1` | `PR #2` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Docs/shared/update readme" |
| 74 | `P2` | `PAD-team1` | `PR #3` | Empty PR description - the README PR template was not filled in (title: "chore(repo): add resource-service and zombie-service as submodules") |
| 76 | `P2` | `PAD-team1` | `PR #4` | Empty PR description - the README PR template was not filled in (title: "docs: update readme") |
| 79 | `P3` | `PAD-team1` | `PR #5` | PR description contains no related-issue reference (`#N`), which the README requires (title: "chore: add base and crafting service submodules") |
| 81 | `P2` | `PAD-team1` | `PR #6` | Empty PR description - the README PR template was not filled in (title: "chore: add base and crafting service submodules (#5)") |
| 82 | `P2` | `PAD-team1` | `PR #7` | Empty PR description - the README PR template was not filled in (title: "chore: update the docs with ruby stack") |
| 84 | `P2` | `PAD-team1` | `PR #8` | Empty PR description - the README PR template was not filled in (title: "docs: add zombie service and resource service endpoints") |
| 87 | `P3` | `PAD-team1` | `PR #9` | PR description contains no related-issue reference (`#N`), which the README requires (title: "Chore/shared/add world exam submodules") |
| 89 | `P6` | `PAD-team1` | `PR #9` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Chore/shared/add world exam submodules" |
| 90 | `P6` | `PAD-team1` | `PR #10` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Chore/shared/add world exam submodules (#9)" |
| 91 | `P2` | `PAD-team1` | `PR #11` | Empty PR description - the README PR template was not filled in (title: "chore/shared/add world exam submodules (#9) #10") |
| 92 | `P6` | `PAD-team1` | `PR #11` | PR title is not a Conventional Commit - it is the auto-generated branch name: "chore/shared/add world exam submodules (#9) #10" |
| 93 | `P7` | `PAD-team1` | `PR #11` | Leading/trailing whitespace in the PR title: " chore/shared/add world exam submodules (#9) #10" |
| 94 | `P2` | `PAD-team1` | `PR #12` | Empty PR description - the README PR template was not filled in (title: "chore: test new branch ruleset в†") |
| 95 | `P8` | `PAD-team1` | `PR #12` | Mojibake / corrupted characters in the PR title: "chore: test new branch ruleset в†" |
| 96 | `P3` | `PAD-team1` | `PR #13` | PR description contains no related-issue reference (`#N`), which the README requires (title: "chore: test new branch ruleset в† (#12)") |
| 97 | `P8` | `PAD-team1` | `PR #13` | Mojibake / corrupted characters in the PR title: "chore: test new branch ruleset в† (#12)" |
| 98 | `P3` | `PAD-team1` | `PR #14` | PR description contains no related-issue reference (`#N`), which the README requires (title: "Docs/shared/add endpoints service boundaries") |
| 99 | `P6` | `PAD-team1` | `PR #14` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Docs/shared/add endpoints service boundaries" |
| 100 | `P2` | `PAD-team1` | `PR #15` | Empty PR description - the README PR template was not filled in (title: "Dev") |
| 101 | `P6` | `PAD-team1` | `PR #15` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Dev" |
| 102 | `P3` | `PAD-team1` | `PR #16` | PR description contains no related-issue reference (`#N`), which the README requires (title: "Docs/endpoints/dmitrii service") |
| 103 | `P6` | `PAD-team1` | `PR #16` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Docs/endpoints/dmitrii service" |
| 104 | `P2` | `PAD-team1` | `PR #17` | Empty PR description - the README PR template was not filled in (title: "Docs/contracts/update service endpoints") |
| 105 | `P6` | `PAD-team1` | `PR #17` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Docs/contracts/update service endpoints" |
| 106 | `P3` | `PAD-team1` | `PR #18` | PR description contains no related-issue reference (`#N`), which the README requires (title: "Dev Changes Endpoints") |
| 107 | `P6` | `PAD-team1` | `PR #18` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Dev Changes Endpoints" |
| 108 | `P3` | `PAD-team1` | `PR #19` | PR description contains no related-issue reference (`#N`), which the README requires (title: "docs: correct README from duplicates") |
| 109 | `P2` | `PAD-team1` | `PR #20` | Empty PR description - the README PR template was not filled in (title: "Dev") |
| 110 | `P6` | `PAD-team1` | `PR #20` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Dev" |
| 111 | `P7` | `PAD-team1` | `PR #20` | Leading/trailing whitespace in the PR title: "Dev " |
| 112 | `P3` | `PAD-team1` | `PR #21` | PR description contains no related-issue reference (`#N`), which the README requires (title: "Chore/shared/update private readme") |
| 113 | `P6` | `PAD-team1` | `PR #21` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Chore/shared/update private readme" |
| 114 | `P2` | `PAD-team1` | `PR #22` | Empty PR description - the README PR template was not filled in (title: "Dev") |
| 115 | `P6` | `PAD-team1` | `PR #22` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Dev" |
| 116 | `P3` | `PAD-team1` | `PR #23` | PR description contains no related-issue reference (`#N`), which the README requires (title: "doc: update arhitecture diagram") |
| 117 | `P6` | `PAD-team1` | `PR #23` | PR title is not a Conventional Commit - it is the auto-generated branch name: "doc: update arhitecture diagram" |
| 118 | `P2` | `PAD-team1` | `PR #24` | Empty PR description - the README PR template was not filled in (title: "doc: update arhitecture diagram (#23)") |
| 119 | `P6` | `PAD-team1` | `PR #24` | PR title is not a Conventional Commit - it is the auto-generated branch name: "doc: update arhitecture diagram (#23)" |
| 120 | `P2` | `PAD-team1` | `PR #25` | Empty PR description - the README PR template was not filled in (title: "Chore/update service references") |
| 121 | `P6` | `PAD-team1` | `PR #25` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Chore/update service references" |
| 122 | `P2` | `PAD-team1` | `PR #26` | Empty PR description - the README PR template was not filled in (title: "Feat/shared/update submodules") |
| 123 | `P6` | `PAD-team1` | `PR #26` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Feat/shared/update submodules" |
| 124 | `P2` | `PAD-team1` | `PR #27` | Empty PR description - the README PR template was not filled in (title: "docs: add Base and Crafting service sections; bump submodules to main") |
| 125 | `P3` | `PAD-team1` | `PR #28` | PR description contains no related-issue reference (`#N`), which the README requires (title: "Dev update") |
| 126 | `P6` | `PAD-team1` | `PR #28` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Dev update" |
| 127 | `P3` | `PAD-team1` | `PR #29` | PR description contains no related-issue reference (`#N`), which the README requires (title: "Revise branch names and clean up PR template section") |
| 128 | `P6` | `PAD-team1` | `PR #29` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Revise branch names and clean up PR template section" |
| 129 | `P2` | `PAD-team1` | `PR #30` | Empty PR description - the README PR template was not filled in (title: "Dev") |
| 130 | `P6` | `PAD-team1` | `PR #30` | PR title is not a Conventional Commit - it is the auto-generated branch name: "Dev" |
| 132 | `P2` | `player-service` | `PR #1` | Empty PR description - the README PR template was not filled in (title: "docs(player-service): add README with Communication Contract sections") |
| 135 | `P2` | `game-service` | `PR #1` | Empty PR description - the README PR template was not filled in (title: "docs(game-service): add README with Communication Contract sections") |

## Process (16)

| # | Rule | Repository | Object | Violation |
|---:|---|---|---|---|
| 137 | `R1` | `PAD-team1` | `issue tracker` | Workflow step 1 ("Create Issue") never followed - 0 issues have ever been opened, so no PR can reference one |
| 138 | `R1` | `player-service` | `issue tracker` | 0 issues ever opened - workflow step 1 ("Create Issue") never followed |
| 139 | `R1` | `game-service` | `issue tracker` | 0 issues ever opened - workflow step 1 ("Create Issue") never followed |
| 140 | `R2` | `PAD-team1` | `.github/` | No `.github/` directory - the PR template the README tells authors to follow does not exist, nor does CODEOWNERS |
| 141 | `R2` | `player-service` | `.github/` | No `.github/` directory - no PR template, no CODEOWNERS |
| 142 | `R2` | `game-service` | `.github/` | No `.github/` directory - no PR template, no CODEOWNERS |
| 143 | `R3` | `PAD-team1` | `README` | README "Branch Structure" documents `development` as the integration branch while "Merging Strategy" and "Workflow Summary" say `dev`; both names were actually used (PRs #5/#9/#10/#11 vs #12-#30) |
| 144 | `R4` | `PAD-team1` | `branch `development`` | The documented integration branch `development` no longer exists on the remote - only `main` and `dev` remain, so the documented branch structure does not match reality |
| 145 | `R5` | `player-service` | `docs/player-service/AddReadme` | Merged branch was never deleted - violates merge process step 5, "Delete feature branch after merge" |
| 146 | `R5` | `game-service` | `docs/game-service/AddReadme` | Merged branch was never deleted - violates merge process step 5, "Delete feature branch after merge" |
| 147 | `R6` | `player-service` | `doc/update` | Stale unmerged branch carrying a README change that was never opened as a PR (commit 29bb1b2 pushed straight to the branch, never reviewed) |
| 148 | `R6` | `game-service` | `doc/update` | Stale unmerged branch carrying a README change that was never opened as a PR (commit 9151ff2 pushed straight to the branch, never reviewed) |
| 149 | `R7` | `PAD-team1` | `branch `private/game-service-submodule`` | A local/private branch was merged straight into `main` (e462f40, b84c6c5 -> b9e5a7c, ec7edc6) with no PR and no review |
| 150 | `R8` | `PAD-team1` | `history` | `main` history is neither clean nor linear: 21 commit subjects each appear twice (duplicated commits from repeated merge-back loops), contradicting the stated benefit of squash-and-merge |
| 151 | `R9` | `PAD-team1` | `CI` | README states "All PRs must pass automated tests before merging" - no GitHub Actions workflow exists, so 0 of 30 PRs were gated by CI |
| 152 | `R10` | `PAD-team1` | `author identities` | Contributors commit under inconsistent identities (DimonBel/Dmitrii Belih, tukaram40k/Ivan Rudenco, danganhuh/Alexandra Mihalevschi, AlexandraB-C/Sasha), making log attribution ambiguous |
---

# Appendix A - What was checked

The README declares these conventions; each became a machine-checked rule.

| README section | Rule(s) derived |
|---|---|
| "Branch Naming Convention": `type/service-name/FeatureName` | `B1` (3 segments), `B4` (middle segment is a real service or `shared`) |
| "Branch Types" table: `feat/ fix/ hotfix/ refactor/ docs/ chore/ test/` | `B2` |
| "Naming Guidelines": "Use lowercase letters in the type and service-name segments" | `B3` |
| "Tools & Resources": "Conventional Commits: For consistent commit messages" | `C2`, `C4`, `C5`, `P6`, `P7`, `P8`, `P9` |
| "Merging Strategy": Squash and Merge, "clean, linear commit history" | `C1`, `R8` |
| "Process": branch from `dev`, PR to `dev`, delete branch after merge | `P4`, `P5`, `R5` |
| "Branch Protection Rules": 1 reviewer minimum | `P1` |
| "Naming Guidelines": "Always reference the related issue number in the PR description" | `P3` |
| "Workflow Summary" step 1 "Create Issue", step 5 "Follow template" | `P2`, `R1`, `R2` |
| "Future Automation": "All PRs must pass automated tests before merging" | `R9` |
| "Branch Structure": `main` + `development` | `R3`, `R4`, `R7` |

Branches whose middle segment is `contracts` (e.g. `docs/contracts/UpdateServiceEndpoints`)
are **not** flagged, because the README's own Branch Types table sanctions the example
`docs/contracts/RefreshApiEndpoints`.

# Appendix B - Fully compliant artifacts

For contrast, these branches do satisfy the naming convention end to end:

- `docs/shared/UpdateReadme` (PR #2)
- `chore/shared/AddBaseCraftingSubmodules` (PR #5)
- `docs/contracts/AddServiceEndpoints` (PR #8)
- `chore/shared/AddWorldExamSubmodules` (PR #9)
- `docs/shared/AddEndpointsServiceBoundaries` (PR #14)
- `docs/contracts/UpdateServiceEndpoints` (PR #17)
- `docs/shared/CorrectREADME` (PR #19)
- `chore/shared/UpdatePrivateREADME` (PR #21)
- `feat/shared/UpdateSubmodules` (PR #26)
- `docs/player-service/AddReadme` (player-service PR #1)
- `docs/game-service/AddReadme` (game-service PR #1)

PR #10 is the only pull request in the entire history whose description references an issue
number. Its two reviews also make it the only PR that comfortably clears the review rule.

# Appendix C - The biggest systemic problems

Ranked by how much of the total they account for:

1. **Squash-merge titles were never edited (19x `P6`, 32x `C2`).** GitHub pre-fills the PR
   title from the branch name, producing `Docs/endpoints/dmitrii service`,
   `Chore/update service references`, `Feat/shared/update submodules`. Nobody replaced them
   with a Conventional Commit subject, so the defect propagated from the PR title straight
   into `main`'s permanent history. Fixing this one habit removes about a third of the list.
2. **`dev` -> `main` release PRs are all titled `Dev`.** Seven PRs (#15, #18, #20, #22, #24,
   #28, #30) carry a title of `Dev`, `Dev `, or `Dev update`, with an empty body. The release
   history of the project is therefore unreadable.
3. **The PR template and issue tracker do not exist.** 0 issues were ever opened across the
   three repositories and there is no `.github/` directory, so "Create Issue" (workflow step 1)
   and "Follow template" (workflow step 5) could not be complied with even in principle. This
   is the root cause of the 18 empty descriptions and 13 missing issue references.
4. **The integration branch was renamed mid-project without updating the README.** PRs #5, #9,
   #10 and #11 target `development`; everything from #12 onward targets `dev`; the README's
   "Branch Structure" section still documents `development`, which no longer exists.
5. **Merge commits and duplicated history.** Despite the declared squash-only strategy, seven
   merge commits reached `main`, and 21 commit subjects appear twice - the history is neither
   clean nor linear.

# Appendix D - Remediation checklist

- [ ] Add `.github/pull_request_template.md` with a "Related issue: #" line, and `.github/CODEOWNERS`.
- [ ] Turn on "Allow squash merging" only, and disable merge commits and rebase merging in repo settings.
- [ ] Set the squash-commit-message default to "Pull request title and description" and require
      Conventional Commit titles via a `commitlint`/`action-semantic-pull-request` workflow.
- [ ] Add a branch-name-validation GitHub Action enforcing `^(feat|fix|hotfix|refactor|docs|chore|test)/[a-z0-9-]+/[A-Za-z0-9-]+$`.
- [ ] Enable "Automatically delete head branches" and clean up `doc/update` and
      `docs/*-service/AddReadme` in `player-service` and `game-service`.
- [ ] Merge or delete the unmerged `doc/update` branches - both hold README content that is not on `main`.
- [ ] Fix the README: pick either `dev` or `development` and use it in all four sections that mention it.
- [ ] Add a CI workflow so the "All PRs must pass automated tests" rule becomes real.
- [ ] Ask each contributor to set a consistent `user.name`/`user.email` matching their GitHub account.

# Appendix E - Note on the count

This audit reports **152** violations. A dashboard figure of 148 is within the normal spread
for this kind of check, because the total depends on rule granularity - for example whether
`DimonBel-patch-1` counts as one branch-naming violation or three (`B1`+`B2`+`B3`), and
whether an empty PR body is also counted as a missing issue reference. Here those two
decisions are made explicitly: `DimonBel-patch-1` is counted three times, and an empty body
(`P2`) suppresses the separate missing-issue-reference finding (`P3`) so the same PR is not
penalised twice for the same blank field. The per-rule table above lets any figure be
reconciled against this one.
