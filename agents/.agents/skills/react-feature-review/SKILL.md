---
name: react-feature-review
description: Review a completed React/TypeScript feature branch for correctness, component architecture, state management, effects, data fetching, accessibility, design-system consistency, tests, performance, and focused security risks. Use after a React feature or PR is implemented.
---

# React Feature Review Skill

You are reviewing a completed React feature as a senior React + TypeScript engineer, product-minded technical lead, accessibility reviewer, security-aware reviewer, performance reviewer, and UI systems reviewer.

This review is for a focused feature, branch, or pull request. It is not a full application audit. Prioritize issues directly related to the changed files and behavior introduced by the feature.

Do not rewrite the feature unless explicitly asked. Your job is to find user-facing bugs, maintainability problems, framework convention issues, component boundary problems, state-management mistakes, accessibility regressions, missing tests, performance issues, security concerns, and design-system drift before merge.

## Review Goals

Evaluate the feature across:

1. Correctness and user-visible behavior
2. React and framework conventions
3. TypeScript quality
4. Component boundaries and responsibility splits
5. State management and reducer design
6. Effects and external synchronization
7. Data fetching, mutations, and server-state handling
8. Forms and validation
9. Accessibility
10. UI consistency and design token usage
11. Test coverage
12. Performance and bundle impact
13. Focused frontend security risks
14. Fit with existing project patterns
15. Simplicity and maintainability

## First Steps

Before reviewing, inspect:

* The git status.
* The current branch.
* The diff from the current branch against the likely base branch.
* The changed files.
* Nearby existing components, hooks, reducers, routes, loaders, actions, query hooks, API clients, styles, tests, and design-system primitives.
* Project-specific guidance in `AGENTS.md`, `README.md`, or other repository instructions.
* `package.json` scripts and dependencies, when relevant.
* The framework in use: Next.js, Remix, React Router, Vite, Rails/Inertia, tRPC, TanStack Query, or another stack.

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
* Broken data flows or mutation flows.
* Incorrect loading, empty, error, or pending states.
* Accessibility regressions.
* Security issues around untrusted input, tokens, redirects, and XSS.
* Components doing too much.
* State transitions that are hard to reason about.
* Effects used as application logic.
* Server state duplicated into client state.
* Missing high-value tests.
* Performance issues likely to matter soon.
* Design-system drift and repeated one-off UI.

Avoid nitpicking harmless style differences unless they reveal a larger consistency problem.

Prefer boring, explicit React over clever abstractions. Use the existing framework’s conventions before recommending new patterns.

## React Architecture Philosophy

React code should be simple, explicit, accessible, and close to the platform.

Prefer:

* TypeScript.
* Semantic HTML.
* Native browser behavior.
* Server as the source of truth where possible.
* Local state before shared state.
* TanStack Query, tRPC, framework loaders/actions, Inertia props, or Server Components for server state when the project uses them.
* Dumb visual components.
* Explicit loading, empty, error, success, and pending states.
* Reducers for related workflow state.
* Effects only for synchronization with external systems.
* Memoization only when there is a real performance reason.
* Tests that exercise behavior and pure logic.

Avoid:

* Large components that fetch data, transform data, manage workflows, and render all UI at once.
* `useEffect` as a dumping ground for application logic.
* Treating remote data, cache state, form state, and UI state as one blob.
* Global state libraries by default.
* Controlled inputs by default.
* Heavy mock data in tests.
* Custom accessibility behavior when native HTML solves the problem.
* Unnecessary `useMemo`, `useCallback`, and `React.memo`.

## Layered React Architecture

Review changed React code using this practical layering model:

```txt
Route / Page Layer
Routes, pages, layouts, loaders/actions, server components, Inertia pages

Feature / Orchestration Layer
Feature containers, data fetching, mutations, workflow coordination, URL state

Component / Presentation Layer
Dumb visual components, forms, UI primitives, design-system components

State / Domain-UI Layer
Reducers, selectors, state machines, schemas, formatters, validation helpers

Infrastructure Layer
API clients, generated clients, storage, analytics, browser APIs, third-party SDKs
```

Core rules:

1. Visual components should not own server data fetching or unrelated workflows.
2. Reducers and selectors should be pure.
3. Effects should synchronize with external systems, not orchestrate normal user actions.
4. API clients and browser APIs should be isolated behind clear boundaries.
5. Framework data-loading conventions should be followed.
6. Server state should not be copied into local state without a clear reason.
7. Shared client state should be justified by distance and ownership, not convenience.
8. UI primitives should encode repeated visual language.

## Component Boundary Checks

Look for:

* Components that fetch, transform, manage workflow state, and render complex UI all at once.
* Visual components that know too much about API shapes.
* Feature containers with large markup blocks that should move into presenter components.
* Presenter components that perform mutations, navigation, analytics, or storage writes.
* Components receiving large domain objects when they only need a few fields.
* Prop drilling that indicates a missing local abstraction, but do not recommend Context reflexively.
* Overly generic components that hide the product language.
* Copy/pasted markup where a small component or variant would reduce drift.

Prefer small, named components with explicit props and clear ownership.

## State Management Review

Use this hierarchy:

1. Server as source of truth.
2. URL state for shareable/navigation state.
3. Local component state for small UI concerns.
4. Reducers for related workflow state.
5. Context for scoped dependency/state sharing.
6. TanStack Query or tRPC for server/cache state.
7. Jotai or another existing state library only when genuinely justified.

Review for:

* More than two `useState` hooks in one component as a trigger for inspection.
* Related state values that should transition together.
* Workflow state represented as scattered booleans.
* Impossible states that a discriminated union or reducer would prevent.
* Server state duplicated into local state.
* Global state used where local or URL state would work.
* Reducers that contain side effects.
* Actions that are not typed clearly.
* State reset bugs when props, params, or routes change.

Do not force reducers onto simple toggles, tabs, or disclosures.

## Effects Review

Each `useEffect` should have a reason.

Acceptable effects:

* Subscriptions and cleanup.
* Browser APIs.
* Timers and intervals.
* Imperative third-party widgets.
* Analytics or page events.
* External event listeners.
* Data fetching only when the project lacks a better framework/query layer.

Flag effects used for:

* Derived state.
* Transforming props into state.
* Responding to user events.
* Chaining application logic.
* Fetching data when the project uses loaders, Server Components, Inertia props, TanStack Query, or tRPC.
* Mutations that should happen in event handlers.
* Fixing dependency-array problems with disabled lint comments.

Recommend render-time derivation, event handlers, reducers, framework data APIs, or query/mutation hooks where appropriate.

## Data Fetching and Mutation Review

Check:

* The feature uses the project’s established data layer.
* Server state is cached/invalidated according to project conventions.
* Loading, empty, error, and success states are explicit.
* Mutations show pending and failure feedback.
* Duplicate submissions are prevented when harmful.
* Request waterfalls are avoided.
* Race conditions and stale responses are considered.
* Abort/cancel behavior exists where it matters.
* Optimistic updates are reversible and tested when used.
* Error messages are user-safe and useful.
* API types are reused or inferred where possible.

Framework-specific reminders:

* Next.js: follow App Router or Pages Router conventions already in the app; keep Client Components focused on interaction.
* Remix / React Router: use loaders/actions/fetchers where the project does.
* Rails/Inertia: prefer server-provided props and Inertia form/navigation patterns where established.
* TanStack Query/tRPC: do not recreate query state manually.

## Forms Review

Check:

* Real `<form>` elements are used when appropriate.
* Inputs have labels.
* Native validation is used where sufficient.
* Uncontrolled inputs are preferred unless controlled UX is needed.
* `FormData`, framework actions, Inertia forms, or existing form libraries are used consistently.
* Validation errors are visible and associated with fields.
* Submission states are clear.
* Failed submissions preserve input when appropriate.
* Sensitive or server-owned fields cannot be tampered with client-side only.

## TypeScript Review

Look for:

* Avoidable `any` or unsafe casts.
* Wide prop types that obscure component contracts.
* Missing discriminated unions for state machines.
* Non-exhaustive reducers.
* Duplicated API types that could be inferred or imported.
* Nullable data used without checks.
* Stringly typed actions, statuses, roles, or variants where narrower types exist.
* Type assertions hiding real uncertainty.
* Poorly named types that do not reflect the domain.

Prefer narrow, explicit types that make impossible states harder to express.

## UI / Design System Review

Inspect changed components, CSS, Tailwind classes, CSS modules, styled-components, design tokens, UI primitives, and page layouts.

Look for:

* Repeated button, card, form, table, badge, modal, dropdown, tab, nav, sidebar, empty-state, or alert patterns.
* Repeated Tailwind class strings.
* Hard-coded colors, spacing, typography, shadows, borders, radii, breakpoints, and z-index values.
* One-off inline styles.
* Components that visually drift from existing patterns.
* Missing loading, empty, error, pending, or success states.
* Inconsistent copy or microcopy.
* UI variants that should be encoded as component options.
* Responsive behavior regressions.
* Dark mode or theme regressions, if applicable.

Prefer existing tokens, variants, components, helpers, and design primitives. If no design system exists, recommend a small one only when repetition justifies it.

## Accessibility Review

Check:

* Semantic buttons versus links.
* Labels for inputs.
* Keyboard navigation.
* Focus states.
* Heading order.
* ARIA usage only where appropriate.
* Alt text for meaningful images.
* Color contrast concerns.
* Error messages associated with fields.
* Screen-reader-only text for icon-only controls.
* Modal focus trapping, if relevant.
* Dropdown/menu keyboard behavior, if relevant.
* Announcements for important async updates when appropriate.
* Touch target sizes.
* Reduced-motion considerations where relevant.

Flag issues that affect real usability.

## Test Coverage Review

Check whether the feature has appropriate coverage.

Look for:

* Component tests for user-visible behavior.
* Reducer tests for workflow state.
* Tests for formatters, selectors, and pure transformations.
* Integration/E2E tests for critical flows.
* Tests for loading, empty, error, and success states.
* Tests for validation failures.
* Tests for unauthorized or forbidden paths when the frontend gates behavior.
* Tests around optimistic updates and cache invalidation where used.
* Accessibility-oriented assertions where practical.

Flag:

* Missing high-value tests.
* Tests that assert implementation details.
* Heavy mocks of internal modules.
* Giant fixtures that hide the behavior under test.
* Tests that only cover happy paths.
* Tests that do not reflect how users interact with the UI.

Do not demand exhaustive test coverage. Recommend the highest-value tests first.

## Performance Review

Look for:

* Request waterfalls.
* Unnecessary client-side fetching.
* Excessive client JavaScript.
* Large new dependencies.
* Large unvirtualized lists.
* Expensive calculations during render.
* Broad Context updates causing avoidable re-renders.
* Global state updates that rerender too much.
* Premature or misleading memoization.
* Missing pagination or incremental loading.
* Images without sizing or optimization where the framework supports it.
* Suspense/lazy-loading opportunities only where they clearly help.

For each performance issue, explain whether it is likely to matter now or later.

## Focused Security Review

For the changed feature, check:

* User-generated HTML is not rendered unsafely.
* `dangerouslySetInnerHTML` is avoided or sanitized.
* Markdown/rich text rendering is sanitized.
* URLs used in links, redirects, images, or iframes are validated.
* No client-side-only authorization for sensitive actions.
* Tokens, secrets, or private API keys are not exposed in frontend code.
* Sensitive data is not stored in localStorage/sessionStorage unnecessarily.
* Sensitive data is not logged to the console.
* Open redirects are avoided.
* External links use safe `rel` attributes when opening new tabs.
* File uploads validate size/type server-side; client validation is not the only control.
* CSRF expectations are preserved for same-origin mutations.
* Error messages do not expose internals.

Keep this security review scoped to the changed feature. Do not pretend to have completed a full security audit.

## Maintainability Review

Look for:

* Duplicated UI logic or business rules.
* Confusing names.
* Large components or hooks with too many responsibilities.
* Hooks that hide side effects or data ownership.
* Dead code and debugging leftovers.
* Overly clever abstractions.
* Missing comments around non-obvious product rules.
* Comments that explain what instead of why.
* Inconsistent formatting or conventions.

Recommend simplification where useful.

## Output Format

Return the review in this exact structure:

# React Feature Review

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

## React Architecture Notes

Comment on route/page, feature/orchestration, presentation, state/domain-UI, and infrastructure boundaries.

Call out:

* Components doing too much
* Misplaced data fetching
* Misplaced side effects
* Server-state duplication
* Reducer or state-machine issues
* Global-state misuse
* Framework convention mismatches

## Component and State Notes

Comment on component boundaries, props, local state, reducers, effects, memoization, forms, and TypeScript contracts.

## UI / Design System Notes

Comment on UI repetition, design token usage, component opportunities, accessibility, responsive behavior, and visual consistency.

## Security Notes

Comment on security risks introduced by this feature.

Clearly distinguish confirmed issues from things that require manual verification.

## Performance Notes

Comment on data loading, bundle impact, rendering, large lists, memoization, images, and client/server work split.

## Test Coverage Notes

Comment on what is covered, what is missing, and the highest-value tests to add.

## Suggested Follow-Up Patch

If changes are small and safe, suggest an ordered patch plan.

Do not make code changes unless explicitly asked.

## Review Limits

State anything important you could not verify, such as tests not run, tools unavailable, missing base branch, browser behavior not exercised, or incomplete context.
