# PAD-team1

# Topic - In Kahoots with the Undead - Communication Contract

This document outlines the communication contracts for the microservices within the **"In Kahoots with the Undead"** platform a zombie-apocalypse survival game set during the FAF university exam season. All services that require user authentication or player-specific information will validate requests using a **JWT (JSON Web Token)** provided in the `Authorization` header.

## Overview

The platform is a distributed set of microservices simulating a persistent, multiplayer survival experience. Players wake up in FAF Cab, scavenge resources, fight zombies, attend PBL presentations, and (hopefully) survive the exam season. Each microservice encapsulates a specific game domain to ensure modularity, independence, and maintainability.

Microservices are implemented using multiple technologies to optimize performance and leverage language-specific strengths:

- **Elixir/Phoenix:** Player Service (Dima), Game Service (Dima), Exam Service (Alexandra), World Service (Alexandra)
- **TypeScript (Node.js / Fastify):** Zombie Service (Ivan), Resource Service (Ivan), Base Service (Sasha), Crafting Service (Sasha)

## Technologies & Communication Patterns

| Owner                    | Services                         | Language & Framework          | Database   | Communication Patterns                                                | Motivation & Trade-offs                                                                                                                                                                                                                                                                   |
| ------------------------ | -------------------------------- | ----------------------------- | ---------- | --------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Dmitrii Belih            | Player Service, Game Service     | Elixir, Phoenix               | PostgreSQL | REST with JWT auth, WebSockets (Phoenix Channels), async timers, CQRS | Phoenix's secure auth plugs and channels are ideal for player identity and real-time gameplay. Elixir's lightweight processes and OTP supervision handle high-concurrency lobbies, day/night cycles and live action progress over WebSockets.                                             |
| Alexandra Mihalevschi    | Exam Service, World Service      | Elixir, Phoenix               | PostgreSQL | REST, Async event-driven updates (PubSub), notifications, CQRS        | Elixir's OTP supervision gives us fault-tolerant exam grading workflows and reliable world-state mutations. Phoenix PubSub makes fanning out `ExamPassed` events to the World Service and achievements effortless.                                                                        |
| Ivan Rudenco             | Zombie Service, Resource Service | TypeScript, Node.js (Fastify) | PostgreSQL | REST, Idempotent operations, Async notification queues, CQRS          | Fastify's low-overhead, schema-validated HTTP layer (with JSON Schema + TypeScript providers) is ideal for read-heavy zombie config endpoints and high-throughput idempotent resource transactions (gain / consume / transfer), backed by Postgres transactions.                          |
| Bujor - Cobili Alexandra | Base Service, Crafting Service   | TypeScript, Node.js (Fastify) | PostgreSQL | REST, Atomic transactions, Async event-driven updates, CQRS           | Fastify plugins keep base upgrades, Kiki rewards and atomic recipe resolution modular and testable. Postgres transactions (via `pg` / `knex` / `Prisma`) make atomic consume-then-credit flows safe, while `fastify-event-bus`-style emitters notify Player Service on inventory changes. |

## Architectural Diagram

![Architectural Diagram](./docs/architecture.png)

The architectural diagram (provided separately by the team) illustrates how the eight microservices interact through the API Gateway and Service Registry. The Game Service sits at the center of the live game loop, while Player, Resource, Exam, World, Zombie, Base and Crafting Services each own a distinct domain. Inter-service communication is a mix of synchronous REST, asynchronous events and WebSocket fan-out.

## Authentication

All endpoints marked with **Headers: `Authorization: Bearer <jwt>`** require a valid JWT issued by the **Player Service**. The token contains:

- `sub` the player UUID
- `roles` e.g. `["player"]`, `["player", "moderator"]`

Cross-service calls (e.g. Game Service в†’ Resource Service) use a dedicated **service-to-service JWT** signed with a shared internal secret.

---

## 1. Player Service

Handles the **global identity and progression** of players: registration, authentication, profiles, friends, online presence, XP, levels and progression. Also owns each player's **persistent inventory** of consumables, cosmetics and other player-owned objects.

### Responsibilities

- Register and authenticate players.
- Issue JWTs upon successful login.
- Manage profiles, XP, levels and progression.
- Manage friends, friend requests and online presence.
- Own the persistent player inventory (consumables, cosmetics, equipment).

### Endpoints

#### Register a Player

`POST /api/players/register`
Description: Creates a new player account.
Payload:

```json
{
  "username": "undead_survivor",
  "email": "player@faf.university",
  "password": "<hashed_password>"
}
```

Success Response (201 Created):

```json
{
  "player_id": "player-uuid-123",
  "username": "undead_survivor",
  "level": 1,
  "xp": 0
}
```

#### Login

`POST /api/players/login`
Description: Authenticates a player and returns a JWT.
Payload:

```json
{
  "email": "player@faf.university",
  "password": "<plain_password>"
}
```

Success Response (200 OK):

```json
{
  "jwt": "<jwt_token>",
  "player_id": "player-uuid-123",
  "roles": ["player"]
}
```

#### Get Player Profile

`GET /api/players/{player_id}`
Description: Retrieves public profile information for a player.
Headers: `Authorization: Bearer <jwt>`
Success Response (200 OK):

```json
{
  "player_id": "player-uuid-123",
  "username": "undead_survivor",
  "level": 7,
  "xp": 1340,
  "university": "FAF",
  "title": "Survivor of the Pumpkin"
}
```

#### Update Player Profile

`PATCH /api/players/{player_id}`
Description: Updates the player's public profile.
Headers: `Authorization: Bearer <jwt>`
Payload:

```json
{
  "title": "Pumpkin Slayer",
  "avatar": "axe_wielding"
}
```

#### Add XP / Level Up

`POST /api/players/{player_id}/xp`
Description: Internal endpoint used by Game Service to award XP. Idempotent via `event_id`.
Headers: `Authorization: Bearer <service_jwt>`
Payload:

```json
{
  "event_id": "evt-uuid-abc",
  "amount": 50,
  "reason": "zombie_killed"
}
```

Success Response (200 OK):

```json
{
  "player_id": "player-uuid-123",
  "xp": 1390,
  "level": 7,
  "leveled_up": false
}
```

#### Get Player Inventory

`GET /api/players/{player_id}/inventory`
Description: Returns the player's full inventory.
Headers: `Authorization: Bearer <jwt>`
Success Response (200 OK):

```json
[
  { "item_id": "coffee-01", "name": "Coffee", "count": 3 },
  { "item_id": "energy-01", "name": "Energy Drink", "count": 1 },
  { "item_id": "sandwich-01", "name": "Davidan Sandwich", "count": 2 },
  { "item_id": "axe-01", "name": "Improvised Axe", "count": 1 }
]
```

#### Add / Remove Inventory Item

`PATCH /api/players/{player_id}/inventory`
Description: Internal endpoint used by Resource / Crafting / Trading flows.
Headers: `Authorization: Bearer <service_jwt>`
Payload:

```json
{
  "operation": "add",
  "item_id": "coffee-01",
  "count": 1,
  "event_id": "evt-uuid-xyz"
}
```

#### Add Friend

`POST /api/players/{player_id}/friends`
Headers: `Authorization: Bearer <jwt>`
Payload:

```json
{ "friend_id": "player-uuid-456" }
```

#### Get Friends List

`GET /api/players/{player_id}/friends`
Headers: `Authorization: Bearer <jwt>`
Success Response (200 OK):

```json
[{ "player_id": "player-uuid-456", "username": "kiki", "status": "online" }]
```

#### Update Presence

`POST /api/players/{player_id}/presence`
Headers: `Authorization: Bearer <jwt>`
Payload:

```json
{ "status": "in_game", "lobby_id": "lobby-uuid-789" }
```

---

## 2. Game Service

The **central real-time gameplay service**. Owns game sessions/lobbies, the day/night cycle, session timers and timed player actions. Also coordinates player trading, zombie behavior and short-lived game events. **Does not permanently own the university map or player inventory.**

### Responsibilities

- Create, join and leave game lobbies.
- Run the day/night cycle and tick timers.
- Start asynchronous actions (chop benches, scavenge canteen, clear room, barricade, repair/upgrade base).
- Push live progress over WebSockets.
- Coordinate trading between players (possibly across universities).
- Verify ownership and perform atomic inventory transfers.
- Manage short-lived zombie behavior during a cycle.
- Notify players and services when actions, attacks or cycles finish.

### REST Endpoints

#### Create a Lobby

`POST /api/game/lobbies`
Headers: `Authorization: Bearer <jwt>`
Payload:

```json
{
  "host_id": "player-uuid-123",
  "university": "FAF",
  "max_players": 8,
  "name": "Cab Survivors"
}
```

Success Response (201 Created):

```json
{
  "lobby_id": "lobby-uuid-789",
  "host_id": "player-uuid-123",
  "university": "FAF",
  "day_cycle": 1,
  "phase": "day",
  "players": ["player-uuid-123"]
}
```

#### Join a Lobby

`POST /api/game/lobbies/{lobby_id}/join`
Headers: `Authorization: Bearer <jwt>`
Payload:

```json
{ "player_id": "player-uuid-456" }
```

#### Leave a Lobby

`POST /api/game/lobbies/{lobby_id}/leave`
Headers: `Authorization: Bearer <jwt>`
Payload:

```json
{ "player_id": "player-uuid-456" }
```

#### Start a Timed Action

`POST /api/game/lobbies/{lobby_id}/actions`
Description: Starts an async action like "chop bench for 10 minutes". Returns immediately; progress is pushed over WebSockets.
Headers: `Authorization: Bearer <jwt>`
Payload:

```json
{
  "player_id": "player-uuid-123",
  "action_type": "chop_bench",
  "target": "bench-room-A1",
  "duration_seconds": 600
}
```

Success Response (202 Accepted):

```json
{
  "action_id": "action-uuid-001",
  "status": "in_progress",
  "started_at": "2026-09-05T10:00:00Z",
  "completes_at": "2026-09-05T10:10:00Z"
}
```

Error Response (409 Conflict):

```json
{ "error": "Player already has an active action." }
```

#### Cancel an Action

`DELETE /api/game/actions/{action_id}`
Headers: `Authorization: Bearer <jwt>`

#### Initiate a Trade

`POST /api/game/lobbies/{lobby_id}/trades`
Description: Initiates a player-to-player trade. Validates ownership and performs the inventory transfer atomically.
Headers: `Authorization: Bearer <jwt>`
Payload:

```json
{
  "from_player_id": "player-uuid-123",
  "to_player_id": "player-uuid-456",
  "offer": [{ "item_id": "coffee-01", "count": 2 }],
  "request": [{ "item_id": "metal-01", "count": 5 }],
  "cross_university": true
}
```

Success Response (200 OK):

```json
{ "trade_id": "trade-uuid-001", "status": "completed" }
```

Error Response (409 Conflict):

```json
{ "error": "Insufficient items to complete trade." }
```

#### Trigger Zombie Encounter

`POST /api/game/lobbies/{lobby_id}/encounters`
Headers: `Authorization: Bearer <service_jwt>` (called by Zombie Service tick)
Payload:

```json
{
  "player_id": "player-uuid-123",
  "zombie_type": "professor_zombie",
  "room_id": "exam-hall-3"
}
```

Success Response (200 OK):

```json
{
  "encounter_id": "encounter-uuid-001",
  "exam_requested": true,
  "exam_id": "exam-uuid-555"
}
```

#### Advance Day/Night Cycle

`POST /api/game/lobbies/{lobby_id}/cycle`
Headers: `Authorization: Bearer <service_jwt>`

### WebSocket Connection

`wss://api.undead/ws/game/lobbies/{lobby_id}?token=<JWT>`

#### Client в†’ Server Events

```json
{ "type": "join_lobby",  "lobby_id": "lobby-uuid-789" }
{ "type": "leave_lobby", "lobby_id": "lobby-uuid-789" }
{ "type": "action_progress_request", "action_id": "action-uuid-001" }
```

#### Server в†’ Client Events

```json
{ "type": "action_started",   "action_id": "...", "player_id": "...", "duration_seconds": 600 }
{ "type": "action_progress",  "action_id": "...", "elapsed_seconds": 120, "percent": 20 }
{ "type": "action_completed", "action_id": "...", "reward": [{ "item_id": "wood-01", "count": 4 }] }
{ "type": "zombie_attack",    "zombie_id": "...", "target_player_id": "...", "damage": 15 }
{ "type": "trade_offer",      "trade_id": "...", "from_player_id": "...", "offer": [...] }
{ "type": "cycle_changed",    "phase": "night", "day": 2 }
{ "type": "encounter_started","encounter_id": "...", "zombie_type": "professor_zombie" }
```

---

## Branch Structure

### Main Branches

- `main` вЂ” Production-ready code, always deployable
- `development` вЂ” Integration branch for features, staging environment

### Branch Protection Rules

- Approvals Required: 1 reviewer minimum
- Dismiss Stale Reviews: Enabled (reviews are dismissed when new commits are pushed)
- Branch must be up to date: Required before merging

### Branch Naming Convention

We follow a standardized naming pattern for all branches:

`type/service-name/FeatureName`

The three segments are:

1. **type** вЂ” the kind of change (see table below).
2. **service-name** вЂ” the microservice the branch targets (e.g. `player-service`, `game-service`, `exam-service`, `world-service`, `zombie-service`, `resource-service`, `base-service`, `crafting-service`).
3. **FeatureName** вЂ” a short PascalCase or kebab-case description of the change. Use present tense for actions.

### Branch Types

| Prefix      | Purpose                   | Example                                            |
| ----------- | ------------------------- | -------------------------------------------------- |
| `feat/`     | New functionality         | `feat/offer-service/CreateOfferEndpoint`           |
| `fix/`      | Bug fixes                 | `fix/zombie-service/ProfessorSpawnLoop`            |
| `hotfix/`   | Critical production fixes | `hotfix/exam-service/GradingCrashOnTimeout`        |
| `refactor/` | Code restructuring        | `refactor/resource-service/IdempotentTransactions` |
| `docs/`     | Documentation updates     | `docs/contracts/RefreshApiEndpoints`               |
| `chore/`    | Maintenance tasks         | `chore/player-service/BumpDependencies`            |
| `test/`     | Adding or fixing tests    | `test/crafting-service/AtomicRecipeCases`          |

### Naming Guidelines

- Use lowercase letters in the **type** and **service-name** segments.
- Use kebab-case or PascalCase in the **FeatureName** segment; keep it concise but descriptive.
- Always include the **service-name** so it is clear which microservice the branch belongs to.
- If the change spans multiple services, use the most relevant primary service or `shared/` (e.g. `feat/shared/CrossServiceEventSchema`).
- Always reference the related issue number in the PR description (not necessarily in the branch name).

## Merging Strategy

**Strategy:** Squash and Merge

### Benefits

- Clean, linear commit history
- Combines all commits from a feature branch into a single commit
- Easier to track features and revert if necessary
- Reduces noise in the main branch history

### Process

1. Create feature branch from `development`
2. Make commits with clear, descriptive messages
3. Open Pull Request to `development`
4. After approval, squash and merge
5. Delete feature branch after merge

## Pull Request Requirements

Every Pull Request must include:

### Required Information

- Clear description of what changed and why
- Issue reference (e.g. "Closes #42", "Fixes #18")
- List of specific changes made
- Testing instructions or results
- Screenshots for UI changes
- Breaking changes (if any)

### PR Template

We use the following template (located at `.github/PULL_REQUEST_TEMPLATE.md`):

```markdown
## What does this PR do?

Brief description of the change and its purpose.

## Related Issue

Closes #XX

## Changes Made

- [ ] Added player inventory endpoint
- [ ] Fixed zombie spawn loop
- [ ] Updated game WebSocket events
- [ ] Improved error handling

## Type of Change

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## How to Test

1. Pull this branch: `git checkout feature/branch-name`
2. Install dependencies
3. Run the application
4. Trigger action "chop bench" and verify XP gain

## Screenshots (if applicable)

[Attach images for UI changes]

## Checklist

- [ ] My code follows the team's coding standards
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
```

## Testing Standards

### Current Requirements

- All new functions should have corresponding tests
- Run existing tests before submitting PR
- Manual testing steps must be documented in PR
- Critical features (trades, crafting, exam grading, resource transfers) require integration testing

### Future Automation

- GitHub Actions will be configured for automatic testing
- All PRs must pass automated tests before merging
- Code coverage reports will be generated

## Versioning Strategy

We follow Semantic Versioning (SemVer): **MAJOR.MINOR.PATCH**

### Version Types

- **MAJOR** (e.g. 1.0.0 в†’ 2.0.0): Breaking changes that require player/admin action
- **MINOR** (e.g. 1.0.0 в†’ 1.1.0): New features that are backward compatible (new zombie type, new recipe, new wing)
- **PATCH** (e.g. 1.0.0 в†’ 1.0.1): Bug fixes and small improvements

### Release Process

1. Update version in each service's build descriptor
2. Create release notes documenting changes
3. Tag release in GitHub: `git tag v1.0.0`
4. Create GitHub Release with changelog
5. Deploy to production

### Release Notes Format

```markdown
## [1.2.0] - 2026-09-05

### Added

- Player inventory persistence
- Professor Zombie exam encounters
- Crafting recipes for barricade kits

### Changed

- Improved trading flow UX
- Updated game WebSocket event payloads

### Fixed

- Zombie spawn loop on night cycle
- Memory leak in resource transactions

### Security

- Updated dependencies with security patches
```

## Code Review Guidelines

In addition to human reviewers, **every PR is automatically reviewed by a local AI code-review agent** that validates the structure of the change against the project's instructions and the service's documented contract. The agent also produces a **step-by-step graded verification report** attached to the PR.

### AI Agent Review (Automated)

The **Team Lead** runs the local AI code-review agent against each newly opened PR on their own machine, then pastes the agent's findings back into the PR thread as **short, actionable instructions** for the author.

### For Reviewers

- Check the AI agent's step-by-step report first.
- Verify functionality matches game-design requirements.
- Test the changes locally when possible.
- Provide constructive feedback tied to the grading rubric above.

### For Authors

- Respond to human feedback promptly and professionally.
- Make requested changes in separate commits so the diff stays reviewable.
- Re-request review after addressing feedback.
- Keep PRs focused and reasonably sized to keep the grading signal meaningful.

## Workflow Summary

1. **Create Issue:** In each lab appear, meeting with team to document the feature/bug with clear requirements
2. **Create Branch:** Use proper naming convention from `development`
3. **Develop:** Make commits with clear, descriptive messages
4. **Test:** Verify functionality and run existing tests
5. **Create PR:** Follow template and provide complete information
6. **Review:** Address feedback and get required approvals
7. **Merge:** Squash and merge to `development`
8. **Deploy:** Regular releases from `development` to `main`

## Tools & Resources

- GitHub Desktop: For GUI-based Git operations
- VS Code: Recommended IDE with Git integration
- GitHub CLI: For command-line operations
- Conventional Commits: For consistent commit messages
- Postman: For designing, sharing and running the REST API requests defined in this contract.
- DBeaver: For browsing and querying the PostgreSQL databases of each service/

## Team Responsibilities

- **All Team Members:** Follow branching strategy and PR requirements
- **Reviewers:** Provide timely, constructive feedback
- **Project Lead:** Manage releases and resolve conflicts
- **QA:** Test major features (trading, crafting, exam grading) before production deployment

## Testing Requirements

- Unit test coverage minimum: **75 %**
