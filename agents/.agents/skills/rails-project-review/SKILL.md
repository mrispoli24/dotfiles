---
name: rails-project-review
description: Perform a full Rails project review covering architecture, Rails conventions, layered design, UI kit consistency, design tokens, test coverage, performance, maintainability, database health, deployment readiness, and security. Use before launch, handoff, or major refactoring.
---

# Rails Project Review Skill

You are performing a full project review as a senior Rails architect, product engineer, security reviewer, performance reviewer, database reviewer, and UI systems reviewer.

This is not a feature PR review. This is a holistic review of the Rails application.

Your job is to identify the highest-leverage improvements needed to make the application maintainable, secure, conventional, scalable, testable, and visually consistent.

Do not rewrite the application unless explicitly asked. Produce a clear review and prioritized remediation plan.

## Review Goals

Evaluate the application across:

1. Rails architecture and conventions
2. Layered Rails architecture
3. Domain modeling
4. Controller/model/service boundaries
5. Authentication and authorization
6. Multi-tenancy and data access boundaries, if applicable
7. UI kit consistency
8. Design token usage
9. View/component repetition
10. Accessibility
11. Test coverage
12. Security posture
13. Performance and database health
14. Background jobs and async workflows
15. Configuration, secrets, and deployment readiness
16. Maintainability and developer experience
17. Product readiness

## First Steps

Inspect the project structure and important files:

* `AGENTS.md`
* `README.md`
* `Gemfile`
* `Gemfile.lock`
* `config/routes.rb`
* `config/application.rb`
* `config/environments`
* `config/initializers`
* `app/models`
* `app/controllers`
* `app/views`
* `app/components`, if present
* `app/services`, if present
* `app/jobs`
* `app/mailers`
* `app/policies`, if present
* `app/helpers`
* `app/javascript`
* `app/assets`
* `app/frontend`, if present
* `db/schema.rb` or `db/structure.sql`
* `db/migrate`
* `test` or `spec`
* CI configuration
* Docker, Kamal, Fly, Heroku, Render, or other deployment files, if present
* Background job configuration
* Authentication and authorization setup
* Any payment, upload, webhook, email, or external integration code

Run or inspect commands where safe:

```sh
git status
bin/rails routes
bin/rails zeitwerk:check
bin/rails test
bundle exec brakeman
bundle exec bundle-audit
```

If the project uses RSpec, prefer:

```sh
bundle exec rspec
```

If JavaScript or frontend checks exist, inspect package scripts and run only if safe:

```sh
cat package.json
```

Do not install new dependencies, run destructive commands, change credentials, or modify code unless explicitly asked.

If tools are unavailable, report that and continue with static review.

## Review Mindset

Be direct, practical, and prioritized.

The goal is not to produce an exhaustive list of every possible imperfection. The goal is to identify what most affects the app’s ability to be safely launched, maintained, extended, and handed off.

Prefer:

* Boring Rails.
* Clear domain names.
* Server-side authorization.
* Database-backed integrity.
* Reusable UI primitives where repetition is real.
* High-value tests over vanity coverage.
* Simple architecture that fits the current app size.
* Domain behavior that lives close to the domain.

Avoid:

* Enterprise architecture for its own sake.
* Generic service-object sprawl.
* Anemic models.
* Premature design systems.
* Overfitting to theoretical scale.
* Nitpicking harmless style differences.

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
8. Infrastructure should be isolated enough that external systems do not leak through the entire app.
9. Presentation should not make business decisions.
10. Application actions should orchestrate workflows without becoming domain dumping grounds.

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
* A mailer computing whether a user is eligible for a workflow should receive prepared state from the domain/application layer.
* A policy performing persistence should move that behavior out of authorization.

## Layer Violation Checks

Actively look for these violations:

* Models reading from `Current.user`, request params, session, cookies, controller state, or view context.
* Models performing HTTP, rendering, email delivery, file delivery, or external API work as surprising side effects.
* Models depending on service objects that belong to the application layer.
* Services accepting `request`, `params`, controller instances, or view helpers directly.
* Controllers performing complex business workflows instead of orchestration.
* Controllers directly talking to third-party clients when an integration boundary would be clearer.
* Views or helpers making business decisions.
* Views or helpers performing authorization logic beyond simple display checks.
* Mailers computing business state instead of receiving prepared data.
* Background jobs containing unrelated business workflows.
* Background jobs duplicating domain logic instead of calling a domain/application action.
* Policies depending on presentation concerns.
* Policies performing persistence or workflow orchestration.
* Infrastructure code leaking into controllers or views.
* Authorization implemented only through hidden UI.
* Query logic copied across controllers, models, services, and views.
* Generic services becoming permanent dumping grounds for behavior that belongs in the domain.
* Concerns used only to hide model size rather than express shared behavior.
* Callbacks triggering cross-domain workflows, external APIs, or irreversible side effects.
* UI components reaching directly into persistence or business workflows.

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
* Long-running external workflow: job that calls an application action.
* Cross-system sync: integration boundary plus idempotent application action.
* Report or export with complex read logic: query/report object.
* Complex presentation state: presenter, component, or view model.

Do not recommend abstractions reflexively. Use the smallest abstraction that clarifies ownership and reduces repetition.

## Architecture Review

Evaluate:

* Is the app organized around real domain concepts?
* Are Rails conventions followed?
* Are controllers thin enough?
* Are models cohesive?
* Are there god objects?
* Are models anemic?
* Are services named around business actions?
* Are services becoming a parallel domain layer?
* Are callbacks appropriate or hiding important workflows?
* Are concerns overused?
* Are helpers hiding business logic?
* Are policies and permissions centralized?
* Are query objects, form objects, presenters, decorators, or components used only where they simplify the app?
* Is there needless abstraction copied from enterprise architectures?
* Is there enough structure for the current app size?
* Are boundaries clear enough for another developer to onboard?
* Are important workflows easy to find?
* Does the folder structure reflect the domain or just technical buckets?
* Are external integrations isolated?
* Are background workflows explicit and recoverable?
* Do lower layers depend on higher layers?
* Does each object pass the specification test?

Prefer boring, clear Rails over clever architecture.

## Rails Layering Standards

Use this rubric.

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
* Contain scattered permission checks.
* Know too much about unrelated models.
* Perform expensive synchronous work unnecessarily.
* Contain large amounts of branching business logic.
* Instantiate low-level infrastructure clients directly when a boundary object would be clearer.

### Models

Models should:

* Represent durable domain concepts.
* Own associations.
* Own validations.
* Own scopes.
* Own small domain methods.
* Protect data integrity with database constraints where appropriate.
* Express important domain rules in clear language.

Models should not:

* Become god objects.
* Become anemic data containers while all behavior lives in services.
* Trigger surprising external side effects.
* Hide large workflows in callbacks.
* Know about HTTP concerns.
* Know about view formatting.
* Know too much about unrelated systems.
* Become the place where every feature gets dumped.
* Read request-specific global state such as params, session, cookies, or controller context.

### Services / Application Actions

Services should:

* Represent clear business actions.
* Have specific names.
* Be easy to test.
* Have explicit inputs and outputs.
* Isolate external integrations where appropriate.
* Make multi-step workflows easier to understand.
* Be used where they reduce complexity, not because of a rule.

Services should not:

* Be generic `Manager`, `Processor`, `Handler`, or `Service` dumping grounds.
* Duplicate model behavior.
* Hide persistence side effects.
* Become long procedural scripts.
* Contain unrelated responsibilities.
* Exist only because code was reflexively moved out of a controller or model.
* Become the permanent home for all domain behavior.

Prefer names like:

* `RegisterAccount`
* `InviteUser`
* `PublishArticle`
* `ProcessLedgerUpload`
* `GenerateInvoice`
* `SyncSubscriptionStatus`
* `ApproveApplication`
* `CreateFamilyCircle`

Avoid vague names like:

* `UserService`
* `AccountManager`
* `DataProcessor`
* `RecordHandler`
* `ApplicationService` subclasses with unclear responsibilities
* `WorkflowService`
* `Utils`

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
* Scope records by user, account, organization, tenant, role, or ownership.
* Avoid relying on hidden buttons or links.
* Be easy to audit.

Flag:

* Missing authorization.
* Scattered authorization.
* Inconsistent policy usage.
* Admin checks implemented only in views.
* Tenant leakage risks.
* Queries that fetch records globally before checking access.
* Policies with business workflow side effects.
* Policies that depend on presentation state.

### Jobs

Jobs should:

* Be idempotent where possible.
* Be retry-safe.
* Handle external API failures.
* Record enough state for recovery.
* Avoid doing too many unrelated things.
* Avoid loading unbounded records into memory.
* Avoid silently swallowing errors.
* Use sensible queue names and priorities.
* Avoid infinite retry loops for permanent failures.
* Delegate business behavior to domain/application actions where appropriate.

Jobs should not become alternate controllers for business workflows.

### Mailers

Mailers should:

* Keep presentation and delivery concerns clear.
* Avoid computing complex business state.
* Avoid leaking sensitive data.
* Use previews where useful.
* Be tested for critical flows.
* Receive prepared state when possible.

Mailers should not own eligibility, authorization, pricing, or workflow decisions.

### Views / Components

Views should:

* Use existing UI primitives.
* Keep logic minimal.
* Use partials or components where repetition is obvious.
* Preserve accessibility.
* Keep business decisions outside templates.
* Be easy to scan.

Views should not:

* Contain business workflows.
* Repeat large chunks of markup.
* Hard-code one-off styles everywhere.
* Bypass the design system.
* Depend on too many instance variables.
* Reimplement the same UI pattern repeatedly.
* Query the database directly.
* Trigger side effects.

## Callback Review

Score callbacks by responsibility.

Keep callbacks that normalize, sanitize, or derive local attributes.

Good callback candidates:

* Normalize email.
* Set local defaults.
* Derive cached local values.
* Normalize phone numbers.
* Strip whitespace from local fields.
* Compute a local slug when safe.

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
* Perform irreversible side effects.

Bad callback candidates:

* Charge a customer.
* Send onboarding emails.
* Create a full project setup.
* Call external APIs.
* Trigger cross-domain side effects.
* Sync a third-party system.
* Perform irreversible operations.
* Create external accounts.
* Start long-running workflows.

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
* `Utilities`
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

## Domain Modeling Review

Evaluate:

* Are model names aligned with the product language?
* Are relationships clear?
* Are ownership boundaries explicit?
* Are account, organization, tenant, user, and role concepts modeled cleanly?
* Are important states represented clearly?
* Are enum values understandable?
* Are state transitions protected?
* Are money values handled safely?
* Are timestamps and time zones handled correctly?
* Are soft deletes used appropriately, if present?
* Are polymorphic associations justified?
* Are JSON columns justified?
* Are important invariants enforced at both application and database levels?
* Is the schema understandable without reading every controller?
* Are domain methods expressive?
* Is domain behavior trapped in generic services instead of the domain?

Flag domain concepts that are missing, overloaded, or poorly named.

## UI Kit and Design Token Review

Inspect the frontend, view layer, components, partials, helpers, CSS, Tailwind configuration, JavaScript behavior, and layout files.

Look for:

* Repeated Tailwind class strings.
* Repeated button styles.
* Repeated form field styles.
* Repeated card styles.
* Repeated table styles.
* Repeated modal/dialog patterns.
* Repeated alert/flash patterns.
* Repeated badge/status pill patterns.
* Repeated dropdown/menu patterns.
* Repeated tab patterns.
* Repeated navigation/sidebar/header patterns.
* Repeated empty states.
* Repeated page headers.
* Repeated list/detail layouts.
* Hard-coded colors.
* Hard-coded spacing.
* Hard-coded typography.
* Hard-coded radius values.
* Hard-coded border styles.
* Hard-coded shadows.
* Hard-coded breakpoints.
* Hard-coded z-index values.
* Inline styles.
* UI variants that should be encoded as component options.
* Similar components built in multiple places.
* Components that visually drift from existing patterns.
* UI code that is difficult to change globally.
* Lack of consistent responsive behavior.
* Lack of consistent loading, empty, and error states.

Recommend:

* Specific components to extract.
* Specific tokens to introduce.
* Specific repeated views to consolidate.
* A small UI kit structure suitable for the project.
* Component APIs where helpful.

Do not recommend a huge design system unless the app clearly needs one.

### Suggested Small Rails UI Kit Structure

If the project would benefit from a lightweight UI kit, consider recommending a structure like:

```txt
app/components/ui/
  button_component.rb
  badge_component.rb
  card_component.rb
  input_component.rb
  textarea_component.rb
  select_component.rb
  modal_component.rb
  alert_component.rb
  table_component.rb
  empty_state_component.rb
  page_header_component.rb
```

or, if the app does not use ViewComponent:

```txt
app/views/shared/ui/
  _button.html.erb
  _badge.html.erb
  _card.html.erb
  _field.html.erb
  _alert.html.erb
  _empty_state.html.erb
  _page_header.html.erb
```

Recommend the lighter option that best matches the existing app.

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
* Modal focus trapping.
* Dropdown/menu keyboard behavior.
* Table semantics.
* Form validation announcements.
* Disabled states.
* Touch target sizes.
* Reduced-motion considerations where relevant.

Flag accessibility issues that affect real usability.

## Security Review

Perform a practical Rails security review.

Clearly separate confirmed issues from items that require manual verification.

### Authentication

Check:

* Login/logout/session handling.
* Password reset flow.
* Password complexity, if applicable.
* Session expiration.
* Remember-me behavior.
* Account confirmation.
* MFA, if applicable.
* OAuth callback handling, if applicable.
* Session fixation protections.
* Brute-force protections, if applicable.
* Whether sensitive actions require re-authentication.

### Authorization

Check:

* Every controller action has clear authorization.
* Users cannot access other users’ records.
* Tenant boundaries are enforced server-side.
* Admin checks do not rely on UI hiding.
* Policies are consistent.
* Record scopes are applied before lookup when needed.
* APIs enforce the same authorization as HTML routes.
* Background jobs do not perform unauthorized actions.
* Direct object reference risks are addressed.

### Multi-Tenancy

If the app is multi-tenant, check:

* Tenant scoping is applied consistently.
* Users cannot switch tenant IDs in params.
* Global IDs are not used unsafely.
* Admin/super-admin access is explicit.
* Background jobs preserve tenant context safely.
* Webhooks map events to tenants safely.
* Queries do not leak cross-tenant data.
* Unique indexes include tenant/account scope where needed.

### Mass Assignment

Check:

* Strong parameters are explicit.
* Sensitive fields are not assignable by users.
* Role/admin/status/tenant/account/organization/user ownership fields are protected.
* Nested attributes are constrained.
* JSON params are not blindly persisted.
* API endpoints do not permit more than intended.

### Injection Risks

Check:

* SQL interpolation.
* Unsafe `order`, `where`, `select`, `pluck`, or raw SQL.
* Shell execution.
* Unsafe deserialization.
* Unsafe dynamic constantization.
* Unsafe `send` or `public_send`.
* Unsafe template rendering.
* Unsafe YAML loading.
* Unsafe JSON parsing assumptions.

### XSS and HTML Safety

Check:

* Unsafe `html_safe`.
* Unsafe `raw`.
* User-generated content rendering.
* Markdown rendering without sanitization.
* Rich text display risks.
* Uploaded SVG or HTML risks.
* JavaScript injection through data attributes.
* Unsafe JSON embedded in script tags.

### CSRF / CORS / Redirects

Check:

* CSRF protection.
* API CSRF expectations.
* Unsafe redirects.
* Open redirect risks.
* Overly permissive CORS.
* Callback URLs.
* Return-to params.
* OAuth redirect URI handling.

### File Uploads

Check:

* Content type validation.
* Extension validation where useful.
* File size limits.
* Direct upload permissions.
* Path traversal.
* Public exposure of private uploads.
* Virus scanning recommendation for sensitive contexts.
* Authorization for download links.
* Signed URL expiration.
* Metadata leakage.

### Secrets and Config

Check:

* Secrets in repo.
* Credentials handling.
* Environment config.
* API keys in frontend code.
* Logging of sensitive values.
* Webhook secrets.
* Master key handling.
* Overly broad credentials.
* Different production/development/test config expectations.
* Secure cookie settings.
* Force SSL settings.

### Payments / Webhooks / External Integrations

If applicable, check:

* Webhook signature verification.
* Idempotency.
* Replay protection.
* Event ordering.
* Error handling.
* Least privilege API keys.
* Sensitive payload logging.
* Payment amount tampering.
* Server-side price calculation.
* Customer ownership checks.
* Subscription state sync.
* Refund/dispute handling.
* Retries and dead-letter behavior.

### Privacy

Check:

* PII in logs.
* PII in URLs.
* PII in error messages.
* PII exposed in admin screens.
* PII in analytics.
* Sensitive exports.
* Data retention concerns.
* User deletion/anonymization expectations.
* Access controls for internal admin tools.

## Performance Review

Check:

* N+1 queries.
* Missing `includes`, `preload`, or `eager_load`.
* Missing indexes.
* Slow dashboard queries.
* Unbounded lists.
* Lack of pagination.
* Expensive synchronous work.
* Inefficient background jobs.
* Repeated external API calls.
* Cache opportunities.
* Large object serialization.
* Hot paths in views.
* Queries in loops.
* Counter cache opportunities.
* Large memory usage.
* Repeated calculations.
* Lack of batching.
* Inefficient imports.
* Inefficient exports.
* Slow tests caused by unnecessary setup.

Explain whether each issue is urgent now or likely to matter later.

## Database Review

Check:

* Missing foreign keys.
* Missing null constraints.
* Missing unique indexes.
* Missing compound indexes.
* Validations not backed by constraints.
* Risky migrations.
* Non-reversible migrations.
* Long-running migrations.
* Data migrations mixed unsafely with schema migrations.
* Polymorphic relationships used unnecessarily.
* JSON columns used where relational modeling would be clearer.
* Counter caches needed or incorrectly maintained.
* Enum values that are hard to evolve.
* Orphaned records.
* Cascading delete behavior.
* Dependent destroy risks.
* Soft delete consistency.
* Inconsistent timestamp usage.
* Timezone assumptions.
* Money stored as floats.
* Missing precision for decimals.
* Lack of audit trail where needed.

Prefer database-level integrity for important business rules.

## Background Jobs and Async Review

Check:

* Queue adapter and production readiness.
* Retry behavior.
* Idempotency.
* Error reporting.
* Dead jobs.
* Job argument serialization.
* Long-running jobs.
* Batch processing.
* Rate limits.
* External API backoff.
* Job fan-out risks.
* Race conditions.
* Duplicate job protection.
* Whether jobs can be safely re-run.
* Whether user-facing state reflects job progress.

## Email and Notification Review

If applicable, check:

* Mailer previews.
* Critical email tests.
* Unsubscribe requirements.
* Sensitive data in emails.
* Deliverability setup.
* Retry behavior.
* Duplicate sends.
* User notification preferences.
* Background delivery.
* Correct environment configuration.

## API Review

If applicable, check:

* Authentication.
* Authorization.
* Rate limiting.
* Pagination.
* Input validation.
* Output serialization.
* Error shapes.
* Versioning.
* Overexposure of fields.
* CORS.
* Idempotency for writes.
* Request logging and sensitive params filtering.

## Testing Review

Evaluate:

* Model tests.
* Request/controller tests.
* System tests.
* Policy tests.
* Job tests.
* Mailer tests.
* Service tests.
* Component tests.
* Integration tests for critical flows.
* Security regression tests.
* Factories or fixtures quality.
* Test speed.
* Flaky tests.
* CI reliability.
* Missing negative cases.
* Missing authorization tests.
* Missing validation failure tests.
* Missing multi-tenant boundary tests.
* Missing webhook tests.
* Missing payment tests, if applicable.

Identify the highest-value missing tests. Do not demand exhaustive coverage for low-risk code.

## Developer Experience Review

Check:

* README setup instructions.
* Environment variable documentation.
* Credentials instructions.
* Seed data.
* Local development workflow.
* Test commands.
* Linting/formatting.
* CI status.
* Error monitoring.
* Logging.
* Debugging leftovers.
* Dead code.
* Naming consistency.
* Directory organization.
* Whether a new developer could reasonably understand the app.

## Deployment Readiness Review

Check:

* Production environment config.
* Database migration safety.
* Asset compilation.
* Background workers.
* Cron/scheduled jobs.
* Email delivery config.
* File storage config.
* SSL settings.
* Host authorization.
* Secrets.
* Logging.
* Error monitoring.
* Health checks.
* Backups.
* Rollback strategy.
* Rate limits.
* Admin access.
* Seed/demo data leakage.
* Debug flags.
* Test credentials in production config.

## Product Readiness Review

Check:

* Broken or missing empty states.
* Broken or missing loading states.
* Broken or missing error states.
* Confusing flows.
* Missing admin workflows.
* Missing recovery paths.
* Missing onboarding.
* Missing confirmations for destructive actions.
* Inconsistent copy.
* Missing user feedback after actions.
* Unhandled failure states for external services.
* Whether the app feels coherent and usable.

## Output Format

Return the review in this exact structure:

# Rails Project Review

## Executive Summary

Give a concise assessment of the project’s health.

Include:

* Overall grade: A, B, C, D, or F
* Launch readiness: Ready, Mostly ready, Risky, or Not ready
* Main concern
* Main strength

## Areas Reviewed

Briefly list the major app areas reviewed and any important areas that could not be inspected.

## Top 10 Findings

For each finding include:

* Severity: Critical, High, Medium, or Low
* Category: Architecture, Rails, Layering, UI, Security, Performance, Database, Tests, DevEx, or Product
* Files or areas affected
* Problem
* Why it matters
* Recommended fix

## Layered Architecture Review

Assess Presentation, Application, Domain, and Infrastructure layer boundaries.

Call out:

* Layer violations
* Reverse dependencies
* Misplaced responsibilities
* Service-object sprawl
* Anemic models
* God objects
* Callback misuse
* Concern misuse
* Query object misuse
* Policy misuse
* Infrastructure leakage
* Objects that fail the specification test

## Architecture and Rails Conventions

Assess the app’s structure, domain modeling, controller/model/service boundaries, naming, RESTfulness, Rails idioms, and maintainability.

## UI Kit and Design System

Assess UI repetition, design tokens, component extraction opportunities, accessibility, and consistency.

Include a proposed small UI kit structure if needed.

## Security Review

List security risks and recommended mitigations.

Clearly separate confirmed issues from things that require manual verification.

## Performance and Database Review

List query, indexing, pagination, caching, migration, and data integrity concerns.

## Background Jobs and Integrations

Assess jobs, emails, webhooks, external APIs, retries, idempotency, and operational safety.

## Test Coverage Review

Identify gaps and the highest-value tests to add first.

## Deployment and DevEx Review

Assess local setup, CI, credentials, deployment readiness, monitoring, logging, and handoff quality.

## Product Readiness Notes

Assess user-facing completeness, empty states, error states, loading states, onboarding, admin flows, and overall usability.

## Refactor Roadmap

Provide a prioritized roadmap:

### Phase 1: Must fix before launch

### Phase 2: Should fix soon

### Phase 3: Nice to improve later

## Suggested Codex Follow-Up Tasks

Provide copy/pasteable Codex prompts for the next 3-7 remediation tasks.

## Review Limits

State anything important you could not verify, such as tests not run, tools unavailable, missing credentials, incomplete environment, or inaccessible external services.

Do not modify code unless explicitly asked.
