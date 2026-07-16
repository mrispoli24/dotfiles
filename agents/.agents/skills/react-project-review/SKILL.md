---
name: react-project-review
description: Perform a full React/TypeScript project review covering architecture, framework conventions, component design, state management, data fetching, accessibility, UI kit consistency, tests, performance, security, deployment readiness, and maintainability. Use before launch, handoff, or major refactoring.
---

# React Project Review Skill

You are performing a full React project review as a senior React + TypeScript architect, product engineer, accessibility reviewer, UI systems reviewer, performance reviewer, security reviewer, and deployment-readiness reviewer.

This is not a feature PR review. This is a holistic review of the React application.

Your job is to identify the highest-leverage improvements needed to make the application maintainable, accessible, secure, performant, testable, visually consistent, and ready to extend or hand off.

Do not rewrite the application unless explicitly asked. Produce a clear review and prioritized remediation plan.

## Review Goals

Evaluate the application across:

1. React and framework architecture
2. TypeScript quality
3. Component boundaries and folder structure
4. State management and reducers
5. Effects and external synchronization
6. Data fetching, mutations, caching, and server-state handling
7. Routing, URL state, and navigation
8. Forms and validation
9. Accessibility
10. UI kit consistency and design token usage
11. Test coverage and test quality
12. Security posture
13. Performance, bundle size, and rendering health
14. Build, deployment, and environment configuration
15. Developer experience and maintainability
16. Product readiness

## First Steps

Inspect the project structure and important files:

* `AGENTS.md`
* `README.md`
* `package.json`
* lockfile: `pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`, or `bun.lockb`
* framework config: `next.config.*`, `vite.config.*`, `remix.config.*`, `react-router.config.*`, `astro.config.*`, or similar
* TypeScript config: `tsconfig*.json`
* lint/format config
* test config: Vitest, Jest, Playwright, Cypress, Testing Library, Storybook, or similar
* app/router entrypoints
* route/page/layout files
* data loading files: loaders, actions, server functions, API routes, query clients, tRPC routers/clients, Inertia pages/props
* components and design-system directories
* hooks
* reducers, stores, contexts, atoms, selectors, schemas, validators, and utilities
* CSS, Tailwind config, CSS modules, theme files, tokens, or styled-components setup
* auth/session code
* API clients and generated clients
* error boundaries
* public assets and image handling
* CI configuration
* deployment files: Docker, Vercel, Netlify, Fly, Render, Rails/Inertia host app, or other platform files
* monitoring, analytics, and environment variable setup

Run or inspect commands where safe:

```sh
git status
cat package.json
```

If scripts exist and are safe, consider:

```sh
npm run typecheck
npm run lint
npm test
npm run test
npm run build
```

Use the package manager already established by the lockfile. Do not install dependencies, run destructive commands, change credentials, or modify code unless explicitly asked.

If tools are unavailable, report that and continue with static review.

## Review Mindset

Be direct, practical, and prioritized.

The goal is not to produce an exhaustive list of every imperfection. The goal is to identify what most affects the app’s ability to be safely launched, maintained, extended, and handed off.

Prefer:

* Boring, explicit React.
* TypeScript that prevents real mistakes.
* Semantic HTML and native browser behavior.
* Framework conventions.
* Server-backed truth where possible.
* Clear route/page, feature, and presentation boundaries.
* Local state before shared state.
* Reducers for meaningful UI workflows.
* Existing query/data tools for server state.
* Small, reusable UI primitives where repetition is real.
* High-value tests over vanity coverage.

Avoid:

* Global state by default.
* Effects as application logic.
* Enterprise architecture for its own sake.
* Premature memoization.
* Overfitting to theoretical scale.
* Heavy component abstractions that hide product language.
* A giant design system when a small UI kit would do.
* Nitpicking harmless style differences.

## React Architecture Philosophy

React code should be easy to reason about.

Use this practical layering model:

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

1. Use the framework’s data and routing conventions.
2. Keep visual components mostly dumb.
3. Keep reducers/selectors pure.
4. Use Effects only for synchronization with external systems.
5. Treat server state and client UI state as different things.
6. Use URL state for shareable navigation state.
7. Reach for Context, Jotai, Zustand, Redux, or other shared state only when ownership and distance justify it or the app already uses them well.
8. Do not copy server state into local state without a clear reason.
9. Isolate API clients, browser APIs, analytics, storage, and SDKs behind clear boundaries.
10. Encode repeated visual language in UI primitives, component variants, or tokens.

## Framework Awareness

Do not assume one React framework. Identify what the project actually uses.

For Next.js:

* Distinguish App Router from Pages Router.
* Prefer Server Components and server data fetching when App Router is established.
* Keep Client Components focused on interaction, local state, and browser APIs.
* Review route handlers, server actions, metadata, image usage, caching, and environment boundaries.

For Remix / React Router:

* Review loaders, actions, fetchers, pending UI, nested routes, error boundaries, and URL state.
* Prefer framework data APIs over ad hoc component fetches.

For Rails/Inertia:

* Prefer server-provided props where appropriate.
* Keep Rails/server as the source of truth.
* Use Inertia forms and navigation patterns when established.
* Review Rails-side authorization, request specs, and system tests if relevant.

For Vite/client React:

* Review query/data layer choice, routing, API clients, environment variables, bundle splitting, and deploy config.

For tRPC/TanStack Query:

* Use generated/type-safe hooks and query invalidation patterns.
* Avoid manually recreating query state.

## Architecture Review

Evaluate:

* Is the app organized around real product features and routes?
* Are route/page components too large?
* Are data fetching and mutations owned by the right layer?
* Are visual components reusable without knowing too much about APIs?
* Are hooks clear boundaries or hidden dumping grounds?
* Are reducers used for real workflow state and kept pure?
* Are effects limited to external synchronization?
* Is server state handled by the framework/query layer?
* Is URL state used for shareable state like filters, search, tabs, and pagination?
* Is global state justified and scoped?
* Are API clients and third-party SDKs isolated?
* Are design-system primitives discoverable?
* Can a new developer find important workflows easily?

Prefer clear product language over generic technical buckets.

## Component and State Standards

### Route / Page Components

Route/page components should:

* Load or receive route-level data according to framework conventions.
* Compose feature and presentation components.
* Handle route params, metadata, navigation, and layout concerns.
* Keep product flow readable.

They should not:

* Contain every detail of a complex page.
* Hide large business workflows inside render logic.
* Duplicate data fetching already handled elsewhere.
* Own unrelated local UI state across many child concerns.

### Feature / Container Components

Feature components should:

* Coordinate data, mutations, workflow state, and user intent.
* Pass explicit props to presenters.
* Keep side effects at clear boundaries.
* Represent a product feature in the app’s language.

They should not:

* Become giant pages under another name.
* Mix API calls, reducers, formatting, styling, and all markup in one file.
* Hide infrastructure details in visual components.

### Presentation Components

Presentation components should:

* Render explicit props.
* Use semantic HTML.
* Preserve accessibility.
* Be easy to test through user-visible behavior.
* Do small display-only formatting where reasonable.

They should not:

* Fetch server data.
* Perform mutations.
* Navigate as a side effect except through explicit callbacks or framework components.
* Read from global stores when props would be clearer.
* Own complex workflows.

### Hooks

Hooks should:

* Encapsulate a coherent piece of behavior.
* Have clear inputs and outputs.
* Respect React hook rules.
* Avoid hiding surprising side effects.

Hooks should not become generic dumping grounds for unrelated data, effects, and state.

### Reducers and State Machines

Reducers should:

* Model related state transitions.
* Be pure.
* Use explicit typed actions.
* Avoid impossible states where practical.
* Be unit tested for important workflows.

Reducers should not:

* Fetch data.
* Navigate.
* Read time, random IDs, localStorage, or browser APIs directly.
* Trigger analytics.
* Duplicate server-cache state.

### Effects

Effects should synchronize with external systems:

* Subscriptions.
* Browser APIs.
* Timers.
* Imperative widgets.
* Analytics.
* External event listeners.

Flag effects used for derived state, user-event handling, application workflows, and data fetching that should belong to the framework/query layer.

## State Management Review

Use this hierarchy:

1. Server as source of truth.
2. URL state for shareable/navigation state.
3. Local component state for simple UI concerns.
4. Reducers for related workflow state.
5. Context for scoped dependencies or subtree state.
6. TanStack Query/tRPC/framework caches for server state.
7. Atom/store libraries for genuinely shared client state when justified.

Review:

* Whether Redux/Zustand/Jotai/Context are overused.
* Whether server and client state are mixed.
* Whether auth/session/user data has a consistent owner.
* Whether filters/search/pagination belong in the URL.
* Whether local state resets correctly across navigation.
* Whether state shapes allow impossible combinations.
* Whether optimistic state is recoverable.

## Data Fetching and API Review

Check:

* Data fetching follows framework conventions.
* API clients are centralized enough to handle auth, errors, base URLs, and response parsing.
* Loading, empty, error, success, and pending states are consistent.
* Mutations invalidate or update cache correctly.
* Duplicate submissions and race conditions are handled where important.
* Request waterfalls are avoided.
* Pagination or incremental loading exists for unbounded lists.
* API response types are reused or inferred.
* Error handling is user-safe.
* Authentication and authorization are enforced server-side, not only in UI.

## Forms and Validation Review

Check:

* Forms use semantic HTML.
* Inputs have labels.
* Native browser validation is used where sufficient.
* Controlled inputs are justified by the UX.
* Form library usage is consistent, if present.
* Server validation errors are displayed accessibly.
* Pending and failure states are clear.
* Sensitive fields are not trusted merely because the frontend hides them.
* Multistep forms have explicit workflow state.

## TypeScript Review

Evaluate:

* Strictness settings.
* Use of `any`, unsafe casts, and non-null assertions.
* Prop types and component contracts.
* API type generation or inference.
* Discriminated unions for state machines.
* Exhaustive reducer checks.
* Shared types that are too wide or too coupled.
* Schema validation for untrusted data where needed.
* Consistency of naming and domain language.

Prefer narrow types that make invalid states hard to represent.

## UI Kit and Design Token Review

Inspect components, CSS, Tailwind config, CSS modules, theme files, tokens, Storybook, and page layouts.

Look for:

* Repeated button styles.
* Repeated form field styles.
* Repeated card, table, badge, modal/dialog, alert, dropdown, tab, nav, sidebar, empty-state, and page-header patterns.
* Repeated Tailwind class strings.
* Hard-coded colors, spacing, typography, shadows, borders, radii, breakpoints, and z-index values.
* Inline styles and one-off variants.
* Similar components built in multiple places.
* Components that visually drift from existing patterns.
* Inconsistent responsive behavior.
* Inconsistent loading, empty, error, and success states.
* Lack of story/documentation for reusable primitives where the app is large enough to need it.

Recommend:

* Specific components to extract.
* Specific tokens to introduce.
* Specific repeated views to consolidate.
* A small UI kit structure suitable for the project.

Do not recommend a huge design system unless the app clearly needs one.

### Suggested Small React UI Kit Structure

If useful, consider recommending a structure like:

```txt
src/components/ui/
  button.tsx
  badge.tsx
  card.tsx
  field.tsx
  input.tsx
  textarea.tsx
  select.tsx
  dialog.tsx
  alert.tsx
  table.tsx
  empty-state.tsx
  page-header.tsx
```

or colocated variants if the project is feature-first.

## Accessibility Review

Check:

* Semantic buttons and links.
* Form labels and descriptions.
* Error message association.
* Keyboard navigation.
* Focus states.
* Heading order.
* ARIA only where semantic HTML is insufficient.
* Modal focus trapping.
* Dropdown/menu keyboard behavior.
* Table semantics.
* Alt text for meaningful images.
* Color contrast.
* Touch target sizes.
* Disabled states.
* `aria-live` for important async updates where appropriate.
* Reduced-motion considerations.
* Route/page title and focus behavior where relevant.

Flag accessibility issues that affect real usability.

## Security Review

Perform a practical frontend security review. Clearly separate confirmed issues from items requiring manual verification.

Check:

### XSS and Content Injection

* `dangerouslySetInnerHTML` usage.
* Markdown/rich text sanitization.
* User-generated HTML or SVG display.
* Unsafe URL interpolation.
* Unsafe JSON embedded into scripts.
* Third-party widget content boundaries.

### Authentication and Authorization

* Sensitive routes are protected server-side.
* UI hiding is not the only authorization control.
* Token/session handling follows platform conventions.
* Auth state does not leak sensitive data.
* Logout clears appropriate client state.

### Secrets and Environment Variables

* Private keys are not exposed to the client bundle.
* Public environment variables are intentionally public.
* Debug flags and test keys are not shipped accidentally.

### Storage and Privacy

* Sensitive data is not stored in localStorage/sessionStorage unnecessarily.
* PII is not logged to the console or analytics.
* URLs do not expose sensitive data.
* Error messages do not reveal internals.

### Navigation and External Resources

* Redirects and return URLs are validated.
* Links opening new tabs use safe `rel` attributes.
* Iframes, images, and external scripts are constrained appropriately.
* CORS/CSRF expectations are understood for API calls.

### Uploads and Downloads

* Client validation is not treated as security.
* File type/size rules are enforced server-side.
* Download URLs are authorized and expire where needed.

## Performance and Bundle Review

Check:

* Bundle size and large dependencies.
* Route-level code splitting.
* Unnecessary client components in server-capable frameworks.
* Request waterfalls.
* Excessive client-side fetching.
* Large unvirtualized lists.
* Expensive render calculations.
* Broad Context/store updates causing rerenders.
* Images missing dimensions, lazy loading, or framework optimization.
* Fonts and third-party scripts.
* Memoization used as a band-aid rather than measured optimization.
* Cache headers and static asset behavior where visible.

Explain whether issues are urgent now or likely to matter later.

## Testing Review

Evaluate:

* Unit tests for reducers, selectors, formatters, and validation helpers.
* Component tests with React Testing Library or equivalent.
* Integration/E2E tests for critical flows.
* Accessibility testing where practical.
* Tests for loading, empty, error, success, and pending states.
* Tests for validation failures.
* Tests for auth/authorization boundaries where frontend behavior matters.
* Query/mutation cache behavior tests where important.
* Mocking strategy.
* Fixture size and maintainability.
* CI reliability.
* Test speed and flakiness.

Prefer behavior tests over implementation details.

## Developer Experience Review

Check:

* README setup instructions.
* Package manager consistency.
* Environment variable documentation.
* Script clarity.
* Typecheck/lint/test/build commands.
* Formatting and linting.
* CI configuration.
* Error boundaries and local debugging ergonomics.
* Storybook or component docs where useful.
* Dead code and debugging leftovers.
* Directory organization.
* Naming consistency.
* Whether a new developer could reasonably understand the app.

## Deployment Readiness Review

Check:

* Production build succeeds.
* Environment variables are documented and separated by environment.
* Public/private env boundaries are correct.
* Routing fallback/static hosting config is correct.
* SSR/edge/serverless assumptions are clear.
* Asset and image handling is production-ready.
* Source maps policy is intentional.
* Error monitoring is configured.
* Analytics are privacy-conscious.
* Cache behavior is understood.
* Health checks or smoke tests exist where appropriate.
* Feature flags and debug code are not accidentally enabled.

## Product Readiness Review

Check:

* Broken or missing empty states.
* Broken or missing loading states.
* Broken or missing error states.
* Confusing flows.
* Missing onboarding.
* Missing confirmations for destructive actions.
* Inconsistent copy.
* Missing user feedback after actions.
* Unhandled failure states for external services.
* Responsive/mobile usability.
* Whether the app feels coherent and usable.

## Output Format

Return the review in this exact structure:

# React Project Review

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
* Category: Architecture, React, TypeScript, State, Data, UI, Accessibility, Security, Performance, Tests, DevEx, or Product
* Files or areas affected
* Problem
* Why it matters
* Recommended fix

## React Architecture Review

Assess route/page, feature/orchestration, presentation, state/domain-UI, and infrastructure boundaries.

Call out:

* Components doing too much
* Misplaced data fetching
* Misplaced side effects
* Server-state duplication
* Global-state misuse
* Reducer/state-machine issues
* Framework convention mismatches
* Infrastructure leakage

## Component, State, and TypeScript Review

Assess component boundaries, props, hooks, reducers, effects, memoization, forms, TypeScript contracts, and maintainability.

## Data Fetching and Routing Review

Assess framework data conventions, API clients, cache invalidation, mutations, URL state, navigation, error boundaries, and route organization.

## UI Kit and Design System

Assess UI repetition, design tokens, component extraction opportunities, accessibility, responsive behavior, and consistency.

Include a proposed small UI kit structure if needed.

## Security Review

List security risks and recommended mitigations.

Clearly separate confirmed issues from things that require manual verification.

## Performance and Bundle Review

List data loading, rendering, memoization, bundle, image, dependency, and client/server split concerns.

## Test Coverage Review

Identify gaps and the highest-value tests to add first.

## Deployment and DevEx Review

Assess local setup, scripts, CI, environment variables, production build, hosting assumptions, monitoring, logging, and handoff quality.

## Product Readiness Notes

Assess user-facing completeness, empty states, error states, loading states, responsive behavior, onboarding, and overall usability.

## Refactor Roadmap

Provide a prioritized roadmap:

### Phase 1: Must fix before launch

### Phase 2: Should fix soon

### Phase 3: Nice to improve later

## Suggested Codex Follow-Up Tasks

Provide copy/pasteable Codex prompts for the next 3-7 remediation tasks.

## Review Limits

State anything important you could not verify, such as tests not run, tools unavailable, missing credentials, incomplete environment, browser behavior not exercised, or inaccessible external services.

Do not modify code unless explicitly asked.
