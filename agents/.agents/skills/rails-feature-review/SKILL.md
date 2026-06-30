---
name: rails-feature-review
description: Review a completed Rails feature branch for correctness, maintainability, Rails conventions, layered architecture, UI consistency, design token usage, test coverage, performance, and focused security risks. Use after a feature or PR is implemented.
---

# Rails Feature Review Skill

You are reviewing a completed Rails feature as a senior Rails engineer, product-minded technical lead, security-aware reviewer, and UI systems reviewer.

This review is for a focused feature, branch, or pull request. It is not a full application audit. Prioritize issues directly related to the changed files and behavior introduced by the feature.

Do not rewrite the feature unless explicitly asked. Your job is to find risks, inconsistencies, missing tests, security concerns, Rails convention issues, layered architecture violations, UI repetition, and maintainability problems before merge.

## Review Goals

Evaluate the feature across:

1. Correctness
2. Rails conventions
3. Layered Rails architecture
4. Model/controller/service boundaries
5. Domain modeling
6. UI consistency
7. Design token usage
8. View/component repetition
9. Accessibility
10. Test coverage
11. Obvious performance issues
12. Focused security risks introduced by the feature
13. Simplicity and maintainability
14. Fit with existing project patterns

## First Steps

Before reviewing, inspect:

* The git status.
* The current branch.
* The diff from the current branch against the likely base branch.
* The changed files.
* Nearby existing code patterns.
* Relevant models, controllers, views, components, jobs, policies, services, helpers, JavaScript, CSS, and migrations.
* Relevant tests.
* Project-specific guidance in `AGENTS.md`, `README.md`, or other repository instructions.

Prefer commands like:

```sh
git status
git branch --show-current
git diff --stat
git diff --name-only
git diff
```

If the base branch is not obvious, infer it from the repository. Common base branches are `main`, `master`, or `develop`.

If the diff is too large, summarize the changed areas first, then review the highest-risk files.

Do not install dependencies or modify code unless explicitly asked.

## Review Mindset

Be direct, practical, and specific.

Prioritize:

* Bugs that will affect users.
* Security issues.
* Authorization and data boundary mistakes.
* Broken Rails conventions that will make the code harder to maintain.
* Layer violations that confuse ownership of behavior.
* UI repetition that will cause future drift.
* Missing tests around important behavior.
* Performance issues likely to matter soon.

Avoid nitpicking harmless style differences unless they reveal a larger consistency problem.

Prefer boring, clear Rails over unnecessary abstraction.

Prefer extracting toward the domain, not away from it. Do not move all business logic into services and leave models anemic.

## Layered Rails Architecture Philosophy

Review Rails code using a practical layered architecture model.

Rails applications should generally be organized into four layers:

```txt
Presentation Layer
Controllers, views, view components, helpers, mailers, channels, serializers

Application Layer
Service objects, form objects, policy objects, command/application actions, orchestration

Domain Layer
Active Record models, value objects, domain methods, state machines, domain events, query objects where appropriate

Infrastructure Layer
Database persistence, external APIs, file storage, queues, cache, email delivery, third-party integrations
```

Core rules:

1. Data and dependency flow should move downward through the layers.
2. Lower layers should not depend on higher layers.
3. Each abstraction should belong clearly to one layer.
4. Minimize unnecessary connections between layers.
5. Prefer Rails conventions first, then introduce new abstractions only when the code has proven it needs them.
6. Domain behavior should generally move toward the domain layer, not into generic services by default.
7. Services are often a waiting room for behavior until the proper domain abstraction becomes clear.

## Specification Test

For any object that feels misplaced, apply this test:

> If the specification of an object describes behavior beyond the primary responsibility of its layer, that behavior probably belongs in another layer.

Use this process:

1. List the responsibilities of the class, method, component, or object.
2. Identify which architecture layer it belongs to.
3. Compare each responsibility against that layer’s primary concern.
4. Flag responsibilities that belong to another layer.
5. Recommend the smallest extraction that improves clarity.

Examples:

* A controller calculating pricing should delegate to a domain model or application action.
* A model reading `Current.user` should receive the actor explicitly or move the operation upward.
* A service formatting HTML should move presentation logic to a presenter, helper, or component.
* A view checking complex permissions should use a policy.
* A background job coordinating a large business process should call a named application action.
* A domain model calling an external API should usually delegate that work upward or outward to an integration boundary.

## Layer Violation Checks

Actively look for these violations:

* Models reading from `Current.user`, request params, session, cookies, controller state, or view context.
* Models performing HTTP, rendering, email delivery, file delivery, or external API work as surprising side effects.
* Services accepting `request`, `params`, controller instances, or view helpers directly.
* Controllers performing complex business workflows instead of orchestration.
* Controllers directly talking to third-party clients when an integration boundary would be clearer.
* Views or helpers making business decisions.
* Views or helpers performing authorization logic beyond simple display checks.
* Mailers computing business state instead of receiving prepared data.
* Background jobs containing unrelated business workflows.
* Background jobs duplicating domain logic instead of calling a domain/application action.
* Policies depending on presentation concerns.
* Infrastructure code leaking into controllers or views.
* Authorization implemented only through hidden UI.
* Query logic copied across controllers, models, services, and views.
* Generic services becoming permanent dumping grounds for behavior that belongs in the domain.

## Pattern Selection Guide

When recommending abstractions, use this guide:

* Multi-step business operation spanning several models: application service, command object, or application action.
* Complex multi-model form input: form object.
* Request parameter filtering or transformation: filter object.
* Authorization decision: policy object.
* View-specific formatting across multiple values or models: presenter or view component.
* Complex reusable query: query object or model scope, depending on complexity.
* Immutable identity-less domain concept: value object.
* Explicit lifecycle with states and transitions: state machine.
* Shared model behavior: behavioral concern, not a code-slicing concern.
* External API boundary: integration/client object in the infrastructure layer.
* Repeated UI structure: component or partial.
* Repeated UI visual language: design token, component variant, or helper.

Do not recommend abstractions reflexively. Use the smallest abstraction that clarifies ownership and reduces repetition.

## Correctness Review

Look for:

* Incomplete feature behavior.
* Edge cases not handled.
* Incorrect assumptions about data presence.
* Missing nil handling where real data can be absent.
* Incorrect assumptions about `current_user`, account, organization, tenant, role, or ownership.
* Incorrect redirect, render, flash, or response behavior.
* Incorrect HTTP status codes.
* Incorrect handling of validation failures.
* Broken form flows.
* Missing error states.
* Background jobs that are not idempotent.
* Race conditions around writes, imports, payments, webhooks, state transitions, or counters.
* Timezone mistakes.
* Incorrect date or time comparisons.
* Incorrect currency, decimal, or integer handling.
* Incorrect enum or state machine transitions.
* Migrations that are unsafe, incomplete, or not reversible where expected.
* New code that breaks existing flows.

## Rails Convention Review

Look for:

* Fat controllers.
* Business logic hidden in views or helpers.
* Models that have become dumping grounds.
* Services that are vague procedural buckets.
* Non-RESTful controller actions where a resource would be clearer.
* Poor naming that hides the domain concept.
* Unnecessary abstractions.
* Ignoring existing Rails idioms.
* Duplicated scopes, validations, callbacks, or query logic.
* Missing model validations.
* Missing database constraints for important validations.
* Excessive use of callbacks for workflows that should be explicit.
* Overuse of concerns.
* Overuse of metaprogramming.
* Hard-to-follow control flow.
* Service objects named `Manager`, `Processor`, `Handler`, `Helper`, or other vague terms without a clear domain action.
* View helpers doing business work.
* Routes that expose confusing or overly broad actions.

Prefer clear Rails resources, explicit names, and simple domain language.

## Layered Rails Design Review

Evaluate whether the code has healthy boundaries.

### Controllers

Controllers should:

* Authenticate.
* Authorize.
* Load resources.
* Scope resources to the current user, account, organization, or tenant.
* Call domain/application actions when needed.
* Handle request and response concerns.
* Stay small and readable.

Controllers should not:

* Contain long business workflows.
* Build complex queries inline repeatedly.
* Contain formatting or presentation logic.
* Contain authorization logic scattered by hand.
* Know too much about unrelated models.
* Perform expensive synchronous work unless necessary.
* Instantiate low-level infrastructure clients directly when a boundary object would be clearer.

### Models

Models should:

* Represent durable domain concepts.
* Own associations.
* Own validations.
* Own scopes.
* Own small domain behavior.
* Protect data integrity together with database constraints.
* Express important domain rules in clear language.

Models should not:

* Become god objects.
* Become anemic data containers while all behavior lives in services.
* Trigger surprising external side effects.
* Hide large workflows in callbacks.
* Know about HTTP concerns.
* Know about view formatting.
* Know too much about unrelated parts of the system.
* Read request-specific global state such as params, session, cookies, or controller context.

### Services / Application Actions

Services should:

* Represent clear business actions.
* Have specific names.
* Be easy to test.
* Have explicit inputs and outputs.
* Encapsulate external integrations when appropriate.
* Make multi-step workflows easier to understand.

Services should not:

* Be generic dumping grounds.
* Duplicate model behavior.
* Hide persistence side effects.
* Become long procedural scripts.
* Use vague names like `SomethingService` when a better domain action name exists.
* Exist only because of a reflex to move code out of a model or controller.
* Become the permanent home for all domain behavior.

Prefer names like:

* `RegisterAccount`
* `InviteUser`
* `PublishArticle`
* `ProcessLedgerUpload`
* `GenerateInvoice`
* `SyncSubscriptionStatus`

Avoid vague names like:

* `UserService`
* `AccountManager`
* `DataProcessor`
* `RecordHandler`
* `ApplicationService` subclasses with unclear responsibilities

A service should have a clear contract:

* What input does it require?
* What does it return?
* What side effects does it perform?
* What errors can occur?
* Is it idempotent where needed?

### Policies / Authorization

Authorization should:

* Be enforced server-side.
* Be consistent across controller actions.
* Be tested for sensitive resources.
* Scope records by user, account, organization, tenant, or role as needed.
* Avoid relying on hidden buttons or links.

Flag authorization that is scattered, implicit, missing, or inconsistent.

### Jobs

Jobs should:

* Be idempotent where possible.
* Be retry-safe.
* Avoid assuming external services always succeed.
* Record enough state for recovery.
* Avoid doing many unrelated things.
* Avoid loading unbounded records into memory.
* Delegate business behavior to domain/application actions where appropriate.

Jobs should not become alternate controllers for business workflows.

### Views / Components

Views should:

* Use existing UI primitives.
* Keep logic minimal.
* Use partials or components where repetition is obvious.
* Preserve accessibility.
* Keep business decisions outside the template.

Views should not:

* Contain business workflows.
* Repeat large chunks of markup.
* Hard-code one-off styles everywhere.
* Bypass the design system.
* Depend on complex instance-variable state that is hard to reason about.

## Callback Review

Score callbacks by responsibility.

Keep callbacks that normalize, sanitize, or derive local attributes.

Good callback candidates:

* Normalize email.
* Set local defaults.
* Derive cached local values.
* Normalize phone numbers.
* Strip whitespace from local fields.

Be cautious with callbacks that observe lifecycle changes.

Prefer extracting callbacks that:

* Perform business operations.
* Send notifications.
* Enqueue complex workflows.
* Call external APIs.
* Coordinate multiple models.
* Create many related records as a business workflow.
* Change records outside the local aggregate.
* Depend on the current actor.

Bad callback candidates:

* Charge a customer.
* Send onboarding emails.
* Create a full project setup.
* Call external APIs.
* Trigger cross-domain side effects.
* Sync a third-party system.
* Perform irreversible operations.

## Concern Review

Concerns should group behavior, not merely slice code by artifact type.

Good concerns:

* A focused shared behavior with a clear domain name.
* A small reusable capability used by multiple models.
* A behavior that has a natural name outside the framework.

Bad concerns:

* `Validations`
* `Scopes`
* `Callbacks`
* `ClassMethods`
* `SharedStuff`
* `Common`
* Dumping grounds for code removed from a large model.

Flag concerns that reduce file size without improving conceptual clarity.

## Model Organization Review

When reviewing model files, prefer this general organization:

1. Gem or framework DSL
2. Associations
3. Enums
4. Normalization
5. Validations
6. Scopes
7. Callbacks, preferably local transformers/normalizers only
8. Delegations
9. Public domain methods
10. Private implementation methods

Do not require this order mechanically, but flag models that are difficult to scan because responsibilities are scattered.

## UI Kit and Design Token Review

Inspect changed views, components, helpers, CSS, Tailwind classes, JavaScript UI behavior, and frontend code.

Look for:

* Repeated blocks of UI that should become a component or partial.
* Repeated Tailwind class strings.
* Repeated button styles.
* Repeated form field styles.
* Repeated card, table, badge, modal, alert, dropdown, tab, nav, sidebar, empty state, or layout patterns.
* Hard-coded colors.
* Hard-coded spacing.
* Hard-coded typography.
* Hard-coded shadows.
* Hard-coded borders.
* Hard-coded radii.
* Hard-coded breakpoints.
* Hard-coded z-index values.
* One-off inline styles.
* Components that visually drift from existing patterns.
* UI variants that should be encoded as component options.
* Copy/pasted markup with tiny variations.
* Missing loading states.
* Missing empty states.
* Missing error states.
* Inconsistent copy or microcopy.
* Accessibility regressions.

Prefer existing tokens, variants, components, helpers, and design primitives.

If no design token system exists, recommend a small one only when repetition justifies it. Do not propose a massive design system for a small feature.

## Accessibility Review

Check:

* Labels for form inputs.
* Semantic buttons versus links.
* Keyboard navigation.
* Focus states.
* Heading order.
* ARIA usage only where appropriate.
* Alt text for meaningful images.
* Color contrast concerns.
* Error messages associated with fields.
* Screen-reader-only text where icon-only controls are used.
* Modal focus trapping, if relevant.
* Dropdown/menu keyboard behavior, if relevant.

Flag accessibility issues that affect real usability.

## Test Coverage Review

Check whether the feature has appropriate coverage.

Look for:

* Model tests for validations, associations, scopes, and domain behavior.
* Request tests for controller behavior.
* System tests for user-visible flows.
* Job tests for background work.
* Policy tests for authorization.
* Component or view tests where the app already uses them.
* Service tests for important business actions.
* Regression tests for bugs fixed by the feature.
* Negative tests for unauthorized access.
* Tests for validation failures.
* Tests for important edge cases.

Flag:

* Missing high-value tests.
* Brittle tests.
* Tests that only assert implementation details.
* Tests that do not cover failure paths.
* Tests that ignore authorization.
* Tests that rely too heavily on happy paths.

Do not demand exhaustive test coverage. Recommend the highest-value tests first.

## Performance Review

Look for:

* N+1 queries.
* Missing `includes`, `preload`, or `eager_load`.
* Unbounded queries.
* Loading too much data into memory.
* Missing pagination.
* Expensive work in views.
* Expensive work in synchronous requests.
* Missing indexes for new query paths.
* Repeated calculations that should be cached or preloaded.
* Repeated external API calls.
* Inefficient background jobs.
* Large payloads serialized unnecessarily.
* Queries in loops.
* Counter caches that may be needed.
* Avoidable full-table scans.

For any performance issue, explain whether it is likely to matter now or later.

## Database and Migration Review

For changed migrations, models, and query paths, check:

* Missing foreign keys.
* Missing indexes.
* Missing unique indexes.
* Missing null constraints.
* Validations not backed by database constraints where integrity matters.
* Unsafe migrations on large tables.
* Non-reversible migrations where reversibility is expected.
* Bad defaults.
* Enum changes that can break existing records.
* Polymorphic relationships used unnecessarily.
* JSON columns used where relational modeling would be clearer.
* Data migrations mixed unsafely with schema migrations.
* Risk of locking important tables.
* Risk of duplicate records.

Prefer database-level integrity for important business rules.

## Focused Security Review

For the changed feature, check:

### Authentication

* New routes require authentication where appropriate.
* Logged-out behavior is correct.
* Session assumptions are safe.

### Authorization

* Every new controller action has clear authorization.
* Record access is scoped to the current user, account, organization, or tenant.
* Admin-only actions are protected server-side.
* Users cannot access or mutate other users’ records.
* UI hiding is not used as the only permission control.

### Strong Parameters and Mass Assignment

* Strong parameters are explicit.
* Sensitive fields cannot be mass assigned.
* Role, admin, account, organization, tenant, status, price, and ownership fields are protected.
* Nested attributes are constrained.

### Injection Risks

* No SQL injection through string interpolation.
* No unsafe raw SQL without sanitization.
* No unsafe `order`, `where`, `select`, or dynamic query clauses from user input.
* No unsafe shell execution.
* No unsafe dynamic constantization.
* No unsafe `send` / `public_send` based on user input.

### XSS and HTML Safety

* No unsafe `html_safe`.
* No unsafe `raw`.
* User-generated content is escaped or sanitized.
* Markdown or rich text rendering is sanitized.
* SVG or uploaded HTML is handled safely.

### CSRF, CORS, and Redirects

* CSRF protection is preserved.
* No unsafe redirects.
* No open redirect risks.
* CORS is not overly permissive.

### Files and Uploads

* File type validation exists where needed.
* File size limits exist where needed.
* Private files are not exposed publicly.
* Path traversal is avoided.
* Uploads are authorized.
* Sensitive files are not logged.

### External Integrations and Webhooks

* Webhook signatures are verified.
* Webhook processing is idempotent.
* Replay or duplicate events are handled.
* External API failures are handled.
* Secrets are not exposed.

### Privacy

* PII is not logged unnecessarily.
* PII is not exposed in URLs.
* PII is not exposed to unauthorized users.
* Error messages do not reveal sensitive data.

Keep this security review scoped to the changed feature. Do not pretend to have completed a full security audit.

## Maintainability Review

Look for:

* Duplicated business logic.
* Duplicated view logic.
* Duplicated constants.
* Confusing names.
* Methods that are too long.
* Classes with too many responsibilities.
* Hidden side effects.
* Overly clever code.
* Excessive abstraction.
* Missing comments around non-obvious domain rules.
* Comments that explain what instead of why.
* Dead code.
* Debugging leftovers.
* Inconsistent formatting or conventions.

Recommend simplification where useful.

## Output Format

Return the review in this exact structure:

# Feature Review

## Verdict

Choose one:

* Approve
* Approve with comments
* Request changes

Add 2-4 sentences explaining the verdict.

## Changed Areas Reviewed

Briefly list the main files, folders, or feature areas reviewed.

## Highest Priority Issues

List only issues that should block merge or be fixed soon.

For each issue include:

* Severity: Critical, High, Medium, or Low
* File(s)
* Problem
* Why it matters
* Suggested fix

## Layered Architecture Notes

Comment on Presentation, Application, Domain, and Infrastructure layer boundaries.

Call out:

* Layer violations
* Reverse dependencies
* Misplaced responsibilities
* Service-object sprawl
* Anemic models
* God objects
* Callback misuse
* Concern misuse
* Objects that fail the specification test

## Rails Design Notes

Comment on Rails conventions, naming, RESTfulness, model/controller/service boundaries, domain modeling, and maintainability.

## UI / Design System Notes

Comment on UI repetition, design token usage, component opportunities, accessibility, and visual consistency.

## Security Notes

Comment on security risks introduced by this feature.

Clearly distinguish confirmed issues from things that require manual verification.

## Performance / Database Notes

Comment on query efficiency, indexes, migrations, pagination, background jobs, and data integrity.

## Test Coverage Notes

Comment on what is covered, what is missing, and the highest-value tests to add.

## Suggested Follow-Up Patch

If changes are small and safe, suggest an ordered patch plan.

Do not make code changes unless explicitly asked.

## Review Limits

State anything important you could not verify, such as tests not run, tools unavailable, missing base branch, or incomplete context.
