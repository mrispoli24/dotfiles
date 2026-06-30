---
name: react
description: Use when writing, reviewing, or refactoring React + TypeScript code. Applies to general React applications, including Vite, Rails/Inertia, Next.js, tRPC, TanStack Query, and other React-based stacks.
---

# React Skill

## Purpose

Use this skill when working in a React codebase.

The goal is to produce React code that is boring, explicit, accessible, testable, and close to the platform. Prefer simple React, native browser behavior, clear component boundaries, and server-backed truth over clever client-side state machinery.

This skill is intentionally framework-aware but not framework-specific. Do not assume Next.js App Router, Server Components, React Router, Rails/Inertia, tRPC, or TanStack Query unless the project already uses them or the user asks for them.

## Core Philosophy

Write React that is easy to reason about.

Prefer:

* TypeScript.
* Semantic HTML.
* Native browser behavior.
* Local state before shared state.
* Server state on the server or in a server-state cache.
* Elm-inspired `model -> view -> update` for complex UI workflows.
* Dumb visual components.
* Explicit loading, empty, error, and success states.
* Reducers for related state transitions.
* Effects only for synchronization with external systems.
* Memoization only when there is a real performance reason.
* Tests that exercise behavior and pure logic.

Avoid:

* Premature `useMemo` and `useCallback`.
* Large components that fetch data, transform data, manage workflows, and render UI all at once.
* `useEffect` as a dumping ground for application logic.
* Treating remote data, cache state, form state, and UI state as one blob.
* Heavy mock data in tests.
* Global state libraries by default.
* Controlled form inputs by default.
* Custom accessibility behavior when native HTML already solves the problem.
* Recreating Elm with unnecessary ceremony in simple React components.

## First Steps Before Editing

Before changing a React codebase:

1. Inspect the project structure.
2. Identify the framework and data-loading model.
3. Identify the test stack.
4. Identify styling conventions.
5. Identify existing state management tools.
6. Follow existing conventions unless they clearly conflict with this skill or the user asks for a refactor.
7. Prefer the smallest useful change.

Do not blindly impose this skill on a mature codebase. Use it to improve code while respecting the surrounding architecture.

If the user asks for a full review, audit the code against this skill and report issues by severity.

## Framework Awareness

This is a general React skill.

Do not assume Next.js App Router.

React may be used with:

* Rails + Inertia.
* Vite.
* Next.js.
* Remix.
* React Router.
* tRPC.
* TanStack Query.
* Server-rendered apps.
* Hybrid apps.
* Client-only apps.

Use the framework's conventions when they exist.

For Rails + Inertia:

* Prefer server-provided props when appropriate.
* Keep Rails/server as the source of truth.
* Use Inertia's form and navigation patterns when already established.
* For browser-level/system tests, prefer the project's Rails system test setup when present.

For Next.js:

* Follow the project's App Router or Pages Router conventions.
* Prefer Server Components and server data fetching when the project uses App Router.
* Keep Client Components focused on interaction, local state, and browser APIs.

For tRPC:

* Prefer generated/type-safe query and mutation hooks when already used by the project.
* Avoid duplicating server state into local reducers unless modeling a local workflow.

For TanStack Query:

* Use it for server state, remote data, caching, loading states, error states, retries, invalidation, and background refresh.
* Do not manually recreate query state with `useState` and `useEffect`.

## TypeScript Defaults

Assume TypeScript unless the project is clearly JavaScript-only.

Prefer:

* Explicit prop types.
* Discriminated unions for reducer actions.
* Narrow types over `any`.
* Type-safe action constants when useful.
* Exhaustive reducer checks.
* Derived types from existing API contracts when possible.

Avoid:

* `any` unless there is a strong reason.
* Repeating server/API types manually when they can be inferred.
* Wide object types passed through many layers without clear contracts.

Example prop type:

```tsx
type InvoiceSummaryProps = {
  id: string;
  customerName: string;
  totalCents: number;
  status: "draft" | "sent" | "paid" | "void";
};

export function InvoiceSummary({
  customerName,
  totalCents,
  status,
}: InvoiceSummaryProps) {
  return (
    <article>
      <h2>{customerName}</h2>
      <p>{formatCurrency(totalCents)}</p>
      <p>{status}</p>
    </article>
  );
}
```

## Component Architecture

Prefer separating orchestration from presentation.

A useful default pattern is:

* Data/container component: fetches or receives data, handles mutations, owns workflows.
* Presenter/visual component: renders the UI, receives explicit props, emits callbacks.
* Reducer/action files: handle complex local state transitions.
* Test files: colocated with the component or reducer.

This maps well to an Elm-inspired architecture:

* **Model**: the TypeScript state shape.
* **View**: the presenter or visual component.
* **Update**: the reducer and action handlers.
* **Effects/Commands**: explicit boundary work, such as mutations, navigation, analytics, browser APIs, timers, or persistence.

Preferred colocated structure:

```txt
features/invoices/
  invoice-list.tsx
  invoice-list.presenter.tsx
  invoice-list.reducer.ts
  invoice-list.actions.ts
  invoice-list.test.tsx
  invoice-list.reducer.test.ts
```

Avoid components that do everything:

```tsx
// Avoid: fetches, transforms, owns state, performs effects, and renders all UI.
export function InvoiceList() {
  // ...
}
```

Prefer:

```tsx
export function InvoiceList() {
  const invoicesQuery = useInvoicesQuery();

  if (invoicesQuery.isLoading) {
    return <InvoiceListPresenter state="loading" />;
  }

  if (invoicesQuery.isError) {
    return <InvoiceListPresenter state="error" />;
  }

  if (invoicesQuery.data.length === 0) {
    return <InvoiceListPresenter state="empty" />;
  }

  return (
    <InvoiceListPresenter
      state="success"
      invoices={invoicesQuery.data}
    />
  );
}
```

The presenter should be as dumb as practical:

```tsx
type InvoiceListPresenterProps =
  | { state: "loading" }
  | { state: "error" }
  | { state: "empty" }
  | { state: "success"; invoices: InvoiceSummary[] };

export function InvoiceListPresenter(props: InvoiceListPresenterProps) {
  if (props.state === "loading") {
    return <p>Loading invoices...</p>;
  }

  if (props.state === "error") {
    return <p>Unable to load invoices.</p>;
  }

  if (props.state === "empty") {
    return <p>No invoices yet.</p>;
  }

  return (
    <ul>
      {props.invoices.map((invoice) => (
        <li key={invoice.id}>{invoice.customerName}</li>
      ))}
    </ul>
  );
}
```

Visual components may do small display-only calculations, such as formatting a phone number or currency value. They should not fetch data, own complex workflows, or coordinate side effects.

## Elm Architecture as a UI Pattern

For complex UI workflows, prefer an Elm-inspired mental model:

* **Model**: the state shape for the UI.
* **View**: the visual rendering of that state.
* **Update**: the pure transition logic that changes the model in response to actions.
* **Effects/Commands**: work that talks to the outside world, such as network requests, browser APIs, analytics, timers, navigation, or persistence.

In React, this usually maps to:

* **Model**: TypeScript state types.
* **View**: dumb presenter components.
* **Update**: `useReducer` reducers and explicit action constants.
* **Effects/Commands**: event handlers, mutation callbacks, framework loaders/actions, TanStack Query/tRPC mutations, or carefully isolated `useEffect` calls.

Use this pattern when the UI has meaningful workflow state, such as:

* Multistep forms.
* Wizards.
* Editors.
* Dashboards with filters and modes.
* Optimistic updates.
* Complex modals.
* Drag-and-drop flows.
* State that has clear transitions.
* UI where many events can change the same state.

Do not force Elm-style structure onto simple components. A toggle, tab, menu, or small disclosure component may only need `useState`.

Good pattern:

```tsx
type Model = {
  selectedCustomerId: string | null;
  lineItems: InvoiceLineItem[];
  status: "idle" | "submitting" | "error" | "success";
  errorMessage: string | null;
};

const ACTIONS = {
  CUSTOMER_SELECTED: "invoice/customerSelected",
  LINE_ITEM_ADDED: "invoice/lineItemAdded",
  SUBMIT_STARTED: "invoice/submitStarted",
  SUBMIT_FAILED: "invoice/submitFailed",
  SUBMIT_SUCCEEDED: "invoice/submitSucceeded",
} as const;

type Action =
  | {
      type: typeof ACTIONS.CUSTOMER_SELECTED;
      payload: { customerId: string };
    }
  | {
      type: typeof ACTIONS.LINE_ITEM_ADDED;
      payload: { item: InvoiceLineItem };
    }
  | {
      type: typeof ACTIONS.SUBMIT_STARTED;
    }
  | {
      type: typeof ACTIONS.SUBMIT_FAILED;
      payload: { message: string };
    }
  | {
      type: typeof ACTIONS.SUBMIT_SUCCEEDED;
    };

function update(model: Model, action: Action): Model {
  switch (action.type) {
    case ACTIONS.CUSTOMER_SELECTED:
      return {
        ...model,
        selectedCustomerId: action.payload.customerId,
      };

    case ACTIONS.LINE_ITEM_ADDED:
      return {
        ...model,
        lineItems: [...model.lineItems, action.payload.item],
      };

    case ACTIONS.SUBMIT_STARTED:
      return {
        ...model,
        status: "submitting",
        errorMessage: null,
      };

    case ACTIONS.SUBMIT_FAILED:
      return {
        ...model,
        status: "error",
        errorMessage: action.payload.message,
      };

    case ACTIONS.SUBMIT_SUCCEEDED:
      return {
        ...model,
        status: "success",
      };

    default:
      return assertNever(action);
  }
}
```

Then wire the update function into React:

```tsx
export function InvoiceEditor() {
  const [model, dispatch] = useReducer(update, initialModel);
  const saveInvoice = api.invoices.save.useMutation();

  async function handleSubmit() {
    dispatch({ type: ACTIONS.SUBMIT_STARTED });

    try {
      await saveInvoice.mutateAsync({
        customerId: model.selectedCustomerId,
        lineItems: model.lineItems,
      });

      dispatch({ type: ACTIONS.SUBMIT_SUCCEEDED });
    } catch (error) {
      dispatch({
        type: ACTIONS.SUBMIT_FAILED,
        payload: { message: "Unable to save invoice." },
      });
    }
  }

  return (
    <InvoiceEditorView
      model={model}
      onCustomerSelected={(customerId) =>
        dispatch({
          type: ACTIONS.CUSTOMER_SELECTED,
          payload: { customerId },
        })
      }
      onLineItemAdded={(item) =>
        dispatch({
          type: ACTIONS.LINE_ITEM_ADDED,
          payload: { item },
        })
      }
      onSubmit={handleSubmit}
    />
  );
}
```

The reducer/update function must stay pure. It should not:

* Fetch data.
* Call mutations.
* Read from local storage.
* Generate random IDs.
* Read the current time.
* Trigger analytics.
* Navigate.
* Touch browser APIs.

Those belong at the boundary, usually in event handlers, query/mutation callbacks, framework actions, or isolated Effects.

The purpose of this pattern is not ceremony. The purpose is to make UI behavior obvious, testable, and stable.

## State Management Hierarchy

Use this state hierarchy:

1. Server as source of truth.
2. URL state for shareable/navigation state.
3. Local component state for small UI concerns.
4. Elm-inspired `model -> view -> update` structure for complex UI workflows.
5. `useReducer` for related local state and explicit state transitions.
6. Context for scoped dependency/state sharing.
7. TanStack Query or tRPC hooks for server/cache state.
8. Jotai for shared client state when truly needed.
9. Other global state tools only when already established or explicitly justified.

Do not reach for global state by default.

Server state is not client state. Remote data, cache state, form draft state, and UI state should not be treated as one generic state blob.

Use Elm-style architecture when UI state has meaningful transitions. Use Jotai when client-only state must be shared across distant parts of the tree and reducer/context becomes awkward. Use TanStack Query or tRPC for server state.

### Local State

Use `useState` for simple, isolated UI state:

```tsx
const [isOpen, setIsOpen] = useState(false);
```

Good uses:

* Toggle state.
* Active tab.
* Local disclosure state.
* Temporary UI affordance.
* Input state only when controlled input behavior is actually needed.

### Reducer Review Trigger

More than two `useState` hooks in one component is a review trigger.

This does not mean every component with three `useState` hooks must become a reducer. It means the code should be inspected.

Refactor to `useReducer` when state values:

* Are related.
* Transition together.
* Require branching logic.
* Represent a workflow.
* Represent a state machine.
* Are frequently updated by the same event handlers.
* Require careful testing.

Acceptable simple state:

```tsx
const [isMenuOpen, setIsMenuOpen] = useState(false);
const [isHelpOpen, setIsHelpOpen] = useState(false);
const [activeTab, setActiveTab] = useState("details");
```

Better as a reducer:

```tsx
const [step, setStep] = useState(1);
const [status, setStatus] = useState<"idle" | "saving" | "error">("idle");
const [errors, setErrors] = useState<FormErrors>({});
const [draft, setDraft] = useState<DraftInvoice>(initialDraft);
```

## Reducers

Prefer `useReducer` when state logic is meaningful.

Reducers are the React implementation of the Elm-style **update** function for local UI workflows.

Reducers should be:

* Pure.
* Unit tested.
* Easy to read.
* Built around explicit actions.
* Free of side effects.
* Free of network calls.
* Free of random IDs unless passed in through the action.
* Free of date/time reads unless passed in through the action.

Prefer action constants and discriminated unions.

Example:

```tsx
export const INVOICE_ACTIONS = {
  CUSTOMER_CHANGED: "invoice/customerChanged",
  LINE_ITEM_ADDED: "invoice/lineItemAdded",
  LINE_ITEM_REMOVED: "invoice/lineItemRemoved",
  SUBMIT_STARTED: "invoice/submitStarted",
  SUBMIT_FAILED: "invoice/submitFailed",
  SUBMIT_SUCCEEDED: "invoice/submitSucceeded",
} as const;

type InvoiceAction =
  | {
      type: typeof INVOICE_ACTIONS.CUSTOMER_CHANGED;
      payload: { customerId: string };
    }
  | {
      type: typeof INVOICE_ACTIONS.LINE_ITEM_ADDED;
      payload: { item: InvoiceLineItem };
    }
  | {
      type: typeof INVOICE_ACTIONS.LINE_ITEM_REMOVED;
      payload: { id: string };
    }
  | {
      type: typeof INVOICE_ACTIONS.SUBMIT_STARTED;
    }
  | {
      type: typeof INVOICE_ACTIONS.SUBMIT_FAILED;
      payload: { message: string };
    }
  | {
      type: typeof INVOICE_ACTIONS.SUBMIT_SUCCEEDED;
    };

type InvoiceState = {
  customerId: string | null;
  lineItems: InvoiceLineItem[];
  status: "idle" | "submitting" | "error" | "success";
  errorMessage: string | null;
};

export function invoiceReducer(
  state: InvoiceState,
  action: InvoiceAction,
): InvoiceState {
  switch (action.type) {
    case INVOICE_ACTIONS.CUSTOMER_CHANGED:
      return {
        ...state,
        customerId: action.payload.customerId,
      };

    case INVOICE_ACTIONS.LINE_ITEM_ADDED:
      return {
        ...state,
        lineItems: [...state.lineItems, action.payload.item],
      };

    case INVOICE_ACTIONS.LINE_ITEM_REMOVED:
      return {
        ...state,
        lineItems: state.lineItems.filter(
          (item) => item.id !== action.payload.id,
        ),
      };

    case INVOICE_ACTIONS.SUBMIT_STARTED:
      return {
        ...state,
        status: "submitting",
        errorMessage: null,
      };

    case INVOICE_ACTIONS.SUBMIT_FAILED:
      return {
        ...state,
        status: "error",
        errorMessage: action.payload.message,
      };

    case INVOICE_ACTIONS.SUBMIT_SUCCEEDED:
      return {
        ...state,
        status: "success",
      };

    default:
      return assertNever(action);
  }
}

function assertNever(value: never): never {
  throw new Error(`Unhandled action: ${JSON.stringify(value)}`);
}
```

Test reducers directly:

```tsx
import { describe, expect, it } from "vitest";
import { INVOICE_ACTIONS, invoiceReducer } from "./invoice-list.reducer";

describe("invoiceReducer", () => {
  it("adds a line item", () => {
    const state = {
      customerId: null,
      lineItems: [],
      status: "idle",
      errorMessage: null,
    } as const;

    const nextState = invoiceReducer(state, {
      type: INVOICE_ACTIONS.LINE_ITEM_ADDED,
      payload: {
        item: {
          id: "line-item-1",
          name: "Design",
          quantity: 1,
          unitPriceCents: 100_00,
        },
      },
    });

    expect(nextState.lineItems).toHaveLength(1);
  });
});
```

## Effects

`useEffect` is an escape hatch for synchronizing React with external systems.

Before adding an Effect, classify it.

Acceptable Effect uses:

* Synchronizing with browser APIs.
* Subscribing to external systems.
* Cleaning up subscriptions.
* Timers and intervals.
* Imperative third-party widgets.
* Analytics/page events.
* External event listeners.
* Data fetching only when the framework or query layer does not provide a better option.

Suspicious Effect uses:

* Derived state.
* Transforming props into state.
* Responding to user events.
* Chaining application logic.
* Updating state because another state value changed.
* Fetching data in a component when the project already uses TanStack Query, tRPC, framework loaders, Inertia props, or Server Components.

Prefer these alternatives before `useEffect`:

* Compute during render.
* Use an event handler.
* Use a parent callback.
* Use a reducer transition.
* Use URL state.
* Use server-rendered props.
* Use TanStack Query or tRPC.
* Use framework data loading.
* Move logic to the server.

Avoid:

```tsx
useEffect(() => {
  setFullName(`${firstName} ${lastName}`);
}, [firstName, lastName]);
```

Prefer:

```tsx
const fullName = `${firstName} ${lastName}`;
```

Avoid:

```tsx
useEffect(() => {
  if (isSubmitted) {
    onSubmit(formData);
  }
}, [isSubmitted, formData, onSubmit]);
```

Prefer:

```tsx
function handleSubmit(event: FormEvent<HTMLFormElement>) {
  event.preventDefault();
  onSubmit(formData);
}
```

Use Effects when synchronizing externally:

```tsx
useEffect(() => {
  const controller = new AbortController();

  window.addEventListener("resize", handleResize, {
    signal: controller.signal,
  });

  return () => controller.abort();
}, []);
```

## Memoization

Do not use `useMemo` or `useCallback` by default.

Use them as performance optimizations only.

Reach for memoization when:

* Profiling shows a real performance issue.
* A calculation is genuinely expensive.
* Stable identity is required for a memoized child.
* Stable identity is required by a dependency array and the surrounding design is otherwise sound.
* A large list or expensive render path benefits from it.

Do not use memoization to make broken logic work.

Avoid reflexive memoization:

```tsx
const handleClick = useCallback(() => {
  setIsOpen(true);
}, []);

const label = useMemo(() => {
  return `${firstName} ${lastName}`;
}, [firstName, lastName]);
```

Prefer simple code:

```tsx
function handleClick() {
  setIsOpen(true);
}

const label = `${firstName} ${lastName}`;
```

When performance matters, measure first if practical. Prefer architectural fixes before render-level micro-optimizations:

* Remove request waterfalls.
* Reduce unnecessary client JavaScript.
* Move data work to the server.
* Split large components.
* Virtualize large lists.
* Avoid unnecessary global state updates.
* Avoid expensive work during render.

## Forms

Prefer native forms and uncontrolled inputs by default.

Use:

* Semantic `<form>`.
* Native `<input>`, `<select>`, `<textarea>`, and `<button>`.
* Real labels.
* Browser validation.
* `FormData`.
* Server-backed submission flows when appropriate.
* Inertia form helpers when in a Rails/Inertia app and already used by the project.

Avoid controlled inputs unless the UX requires them.

Good default:

```tsx
type ContactFormProps = {
  onSubmit: (values: { name: string; email: string; message: string }) => void;
};

export function ContactForm({ onSubmit }: ContactFormProps) {
  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const formData = new FormData(event.currentTarget);

    onSubmit({
      name: String(formData.get("name") ?? ""),
      email: String(formData.get("email") ?? ""),
      message: String(formData.get("message") ?? ""),
    });
  }

  return (
    <form onSubmit={handleSubmit}>
      <label htmlFor="name">Name</label>
      <input id="name" name="name" required />

      <label htmlFor="email">Email</label>
      <input id="email" name="email" type="email" required />

      <label htmlFor="message">Message</label>
      <textarea id="message" name="message" required />

      <button type="submit">Send message</button>
    </form>
  );
}
```

Use controlled inputs for:

* Live search.
* Live preview.
* Dependent fields.
* Input masks.
* Rich text.
* Custom validation timing.
* Autosave.
* Collaborative editing.
* Complex multistep forms.
* Cases where React state must be the immediate source of truth.

If a form library is needed, prefer React Hook Form unless the project has already chosen another tool. React Hook Form is a good fit because it works well with uncontrolled inputs and avoids re-rendering on every keystroke by default.

## Data Fetching

Use the project's data-fetching model.

Do not scatter ad hoc fetching throughout visual components.

Preferred patterns:

* Rails/Inertia: server-provided props and Inertia form/navigation helpers.
* Next.js App Router: Server Components and server data fetching by default; Client Components for interaction.
* TanStack Query: queries and mutations for server/cache state.
* tRPC: type-safe query and mutation hooks.
* Vite/client React: TanStack Query or an established project data layer.

Avoid:

```tsx
useEffect(() => {
  fetch("/api/invoices")
    .then((response) => response.json())
    .then(setInvoices)
    .catch(setError);
}, []);
```

Prefer the project's data layer:

```tsx
const invoicesQuery = api.invoices.list.useQuery();
```

or:

```tsx
const invoicesQuery = useQuery({
  queryKey: ["invoices"],
  queryFn: fetchInvoices,
});
```

or framework-provided props:

```tsx
export function InvoicePage({ invoices }: { invoices: Invoice[] }) {
  return <InvoiceListPresenter state="success" invoices={invoices} />;
}
```

## Rendering States

Every async user-facing flow should account for:

* Idle.
* Loading.
* Empty.
* Error.
* Success.
* Submitting/saving when relevant.
* Disabled/pending state when relevant.

Users should never press a button and wonder whether anything happened.

For data fetching:

```tsx
if (query.isLoading) {
  return <p>Loading...</p>;
}

if (query.isError) {
  return <p>Something went wrong.</p>;
}

if (query.data.length === 0) {
  return <p>No results found.</p>;
}

return <ResultsList results={query.data} />;
```

For mutations:

```tsx
<button type="submit" disabled={mutation.isPending}>
  {mutation.isPending ? "Saving..." : "Save"}
</button>
```

Prefer visible feedback over silent state changes.

## Props

Props should make component contracts clear.

Prefer explicit props when a component only needs a few fields:

```tsx
<UserCard
  name={user.name}
  email={user.email}
  avatarUrl={user.avatarUrl}
/>
```

Prop spreading is allowed when:

* The receiving component genuinely accepts the full prop object.
* Forwarding known safe props.
* Passing component props through a wrapper.
* The spread improves clarity.

Acceptable:

```tsx
<Button {...buttonProps} />
```

Acceptable:

```tsx
<UserCard {...pickUserCardProps(user)} />
```

Avoid spreading large domain objects into components that only need a few fields:

```tsx
<UserCard {...user} />
```

Do not pass entire objects only because it is convenient. Component APIs should communicate what the component actually needs.

## Accessibility

Accessibility is not optional.

Prefer semantic HTML before custom components.

Rules:

* Use `<button>` for actions.
* Use `<a>` for navigation.
* Every input must have a label.
* Do not use `div` or `span` as fake buttons.
* Preserve keyboard access.
* Preserve visible focus states.
* Use native form validation where possible.
* Use ARIA only when semantic HTML is insufficient.
* Ensure loading, error, empty, and success states are perceivable.
* Disable buttons during pending submits when duplicate actions would be harmful.
* Use `aria-live` for important async feedback when appropriate.
* Do not hide critical feedback only in color.

Bad:

```tsx
<div onClick={onSave}>Save</div>
```

Good:

```tsx
<button type="button" onClick={onSave}>
  Save
</button>
```

Bad:

```tsx
<input name="email" />
```

Good:

```tsx
<label htmlFor="email">Email</label>
<input id="email" name="email" type="email" required />
```

## Styling

This skill does not mandate Tailwind, CSS Modules, styled-components, shadcn/ui, Radix, or any other styling tool.

Follow the project's styling system.

When writing plain CSS, CSS Modules, inline styles, or style objects, prefer logical ordering:

1. Positioning.
2. Box model and layout.
3. Typography.
4. Visual styles.

Example:

```css
.card {
  position: relative;

  display: flex;
  width: 100%;
  padding: 1rem;

  font-size: 1rem;
  line-height: 1.5;

  color: var(--color-text);
  background: white;
  border: 1px solid var(--color-border);
}
```

Do not churn existing CSS just to reorder properties. Respect the project's formatter and lint rules.

## Testing

Prefer:

* Vitest for unit tests when used by the project.
* React Testing Library for React behavior tests.
* Rails system tests/Selenium when working in a Rails/Inertia app that already uses Rails defaults.
* Playwright for TypeScript-heavy end-to-end/browser testing stacks.
* Pure unit tests for reducers, selectors, formatters, and state transitions.

Test behavior, not implementation details.

Good component test:

```tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { ContactForm } from "./contact-form";

describe("ContactForm", () => {
  it("submits the form values", async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();

    render(<ContactForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText("Name"), "Ada Lovelace");
    await user.type(screen.getByLabelText("Email"), "ada@example.com");
    await user.type(screen.getByLabelText("Message"), "Hello.");

    await user.click(screen.getByRole("button", { name: "Send message" }));

    expect(onSubmit).toHaveBeenCalledWith({
      name: "Ada Lovelace",
      email: "ada@example.com",
      message: "Hello.",
    });
  });
});
```

Avoid tests that depend on internal component structure.

Bad:

```tsx
expect(wrapper.find(".submit-button").prop("disabled")).toBe(true);
```

Better:

```tsx
expect(screen.getByRole("button", { name: "Saving..." })).toBeDisabled();
```

## Mocking

Mocking is allowed, but heavy mocking is a code smell.

Mock at system boundaries:

* Network boundary.
* Time boundary.
* Browser API boundary.
* Third-party service boundary.
* Authentication/session boundary when needed.

Avoid mocking your own internal modules just to make tightly coupled code testable.

If a test needs a giant fake object, many mocked modules, or deeply nested fixture data, consider:

* Extracting a pure function.
* Extracting a reducer.
* Creating a smaller component contract.
* Creating a fixture builder.
* Testing the integration at a higher level.
* Moving logic out of the visual component.

Prefer small builders over massive fixtures:

```tsx
function buildInvoice(overrides: Partial<Invoice> = {}): Invoice {
  return {
    id: "invoice-1",
    customerName: "Acme Co.",
    totalCents: 100_00,
    status: "draft",
    ...overrides,
  };
}
```

Do not create huge mock data files that obscure what the test actually cares about.

## Event Handling

Prefer event handlers for user actions.

Do not route user events through Effects.

Good:

```tsx
function handleDeleteClick() {
  deleteInvoiceMutation.mutate({ id: invoice.id });
}
```

Avoid:

```tsx
useEffect(() => {
  if (shouldDelete) {
    deleteInvoiceMutation.mutate({ id: invoice.id });
  }
}, [shouldDelete, invoice.id, deleteInvoiceMutation]);
```

Use parent callbacks when child components should report intent:

```tsx
type InvoiceRowProps = {
  invoice: InvoiceSummary;
  onDelete: (id: string) => void;
};

export function InvoiceRow({ invoice, onDelete }: InvoiceRowProps) {
  return (
    <tr>
      <td>{invoice.customerName}</td>
      <td>
        <button type="button" onClick={() => onDelete(invoice.id)}>
          Delete
        </button>
      </td>
    </tr>
  );
}
```

In an Elm-inspired workflow, event handlers often serve as the boundary between user intent and the update function:

```tsx
function handleLineItemAdded(item: InvoiceLineItem) {
  dispatch({
    type: ACTIONS.LINE_ITEM_ADDED,
    payload: { item },
  });
}
```

If the event requires outside-world work, keep that work outside the reducer:

```tsx
async function handleSubmit() {
  dispatch({ type: ACTIONS.SUBMIT_STARTED });

  try {
    await saveInvoice(model);
    dispatch({ type: ACTIONS.SUBMIT_SUCCEEDED });
  } catch {
    dispatch({
      type: ACTIONS.SUBMIT_FAILED,
      payload: { message: "Unable to save invoice." },
    });
  }
}
```

## Derived Data

Prefer deriving values during render when cheap.

Good:

```tsx
const completedCount = tasks.filter((task) => task.completed).length;
```

Avoid unnecessary state:

```tsx
const [completedCount, setCompletedCount] = useState(0);

useEffect(() => {
  setCompletedCount(tasks.filter((task) => task.completed).length);
}, [tasks]);
```

If derived data is expensive, consider:

1. Whether the data can be derived on the server.
2. Whether the component can be split.
3. Whether the calculation can be moved out of render.
4. Whether `useMemo` is justified.

## Context

Use Context sparingly.

Good uses:

* Theme.
* Current user/session object.
* Feature flags.
* Locale.
* Scoped dependencies.
* A reducer-backed workflow for a specific subtree.

Avoid using Context as a dumping ground for all app state.

If Context causes broad re-renders or unclear dependencies, consider:

* Splitting contexts.
* Moving state closer to where it is used.
* Using TanStack Query for server state.
* Using Jotai for shared client state when justified.

## External State Libraries

Do not add a global state library by default.

Preferred order:

1. Local state.
2. Elm-inspired reducer/update pattern.
3. Context for a scoped subtree.
4. TanStack Query or tRPC for server/cache state.
5. Jotai for shared client state that is not server state.

Use Jotai when:

* State is genuinely client-only.
* Multiple distant components need it.
* Context would become awkward or cause excessive re-renders.
* The state is small and atom-oriented.

Do not use Jotai for server cache state that belongs in TanStack Query or tRPC query hooks.

Do not introduce Redux, Zustand, MobX, or another state library unless:

* The project already uses it.
* The user asks for it.
* There is a specific architectural reason.

## Lists and Keys

Always use stable keys.

Good:

```tsx
{invoices.map((invoice) => (
  <InvoiceRow key={invoice.id} invoice={invoice} />
))}
```

Avoid index keys when list order can change:

```tsx
{invoices.map((invoice, index) => (
  <InvoiceRow key={index} invoice={invoice} />
))}
```

Index keys are acceptable only for truly static lists that will not be reordered, inserted into, or deleted from.

## Error Handling

User-facing errors should be visible and useful.

Avoid swallowing errors silently.

For expected errors:

* Show a message.
* Preserve user input when possible.
* Offer a retry when appropriate.
* Avoid exposing raw internal error details.

For unexpected errors:

* Let the framework error boundary handle it when appropriate.
* Add an error boundary for isolated parts of the UI when useful.
* Log/report according to the project's conventions.

## Performance

Optimize the right thing first.

Before adding memoization, look for:

* Request waterfalls.
* Excessive client JavaScript.
* Large bundles.
* Unnecessary client-side data fetching.
* Expensive render loops.
* Large unvirtualized lists.
* Unstable global state updates.
* Too much work in visual components.
* Avoidable re-renders caused by broad Context.

Use `React.memo`, `useMemo`, and `useCallback` only when justified.

Performance work should ideally be supported by:

* React Profiler.
* Browser performance tools.
* Bundle analysis.
* Known expensive paths.
* User-visible slowness.

Do not make code harder to read for theoretical performance.

## Code Review Checklist

When reviewing React code, check:

### Architecture

* Is the component doing too much?
* Is data fetching separated from visual rendering?
* Are visual components mostly dumb?
* Does the code follow the framework's conventions?
* Is the server treated as the source of truth where appropriate?
* Would an Elm-inspired `model -> view -> update` structure make this workflow clearer?

### State

* Is local state sufficient?
* Are there more than two `useState` hooks?
* Are related state transitions modeled with a reducer?
* Is server state being duplicated into client state?
* Is global state being introduced unnecessarily?
* Is Jotai being used only for client state that truly needs to be shared?
* Is TanStack Query or tRPC being used for server/cache state where appropriate?

### Reducers / Update Functions

* Is the reducer pure?
* Are actions explicit?
* Are actions typed as a discriminated union?
* Are action constants used where helpful?
* Are side effects kept outside the reducer?
* Is the reducer unit tested?
* Does the reducer model a real workflow or just add ceremony?

### Effects

* Is each `useEffect` synchronizing with an external system?
* Could the logic be computed during render?
* Could the logic live in an event handler?
* Could the logic live in a parent callback?
* Could the logic live in a reducer transition?
* Could the framework or query layer handle the work?

### Memoization

* Are `useMemo` and `useCallback` actually needed?
* Is there evidence of a performance issue?
* Is memoization being used to fix broken logic?

### Forms

* Are forms semantic?
* Are inputs labeled?
* Is native validation being used where possible?
* Are uncontrolled inputs sufficient?
* Is controlled state justified by the UX?

### Data Fetching

* Are loading, empty, error, and success states handled?
* Is the project's data layer being used?
* Is fetch logic kept out of dumb visual components?
* Are mutations giving users feedback?

### Testing

* Are reducers tested as pure functions?
* Do component tests focus on user-visible behavior?
* Are mocks kept at system boundaries?
* Is heavy mock data hiding design problems?

### Accessibility

* Are buttons buttons?
* Are links links?
* Can the UI be used with a keyboard?
* Are focus states preserved?
* Are important state changes visible or announced?

### Props

* Are props explicit enough?
* Is prop spreading used responsibly?
* Are large domain objects being passed where only a few fields are needed?

## Refactoring Guidance

When refactoring, prefer small safe steps:

1. Extract a presenter component.
2. Extract pure formatting or transformation helpers.
3. Replace derived state Effects with render-time values.
4. Identify whether the UI has an Elm-style workflow hiding inside it.
5. Move related state into a reducer/update function.
6. Add explicit action constants and action types.
7. Add reducer tests.
8. Move server state into the project's query/data layer.
9. Add loading/error/empty/success states.
10. Improve accessibility.
11. Remove unnecessary memoization.
12. Add focused tests.

Do not perform broad rewrites unless the user asks for them.

## Agent Behavior

When this skill is active:

* Be opinionated but not reckless.
* Explain when a recommendation is a house preference rather than universal React law.
* Prefer direct code improvements over abstract advice.
* Preserve existing project conventions unless there is a clear reason to change them.
* Avoid adding libraries without justification.
* Avoid premature optimization.
* Avoid framework assumptions.
* Reach for Elm-inspired `model -> view -> update` when it clarifies complex UI workflows.
* Do not force Elm-style ceremony onto simple components.
* Ask for clarification only when the missing answer materially changes the implementation.
* If asked for a review, produce concrete findings with suggested fixes.
* If asked to refactor, make the smallest change that moves the code toward this skill.

## Summary

Good React code should be simple, explicit, accessible, and boring.

Keep the server as the source of truth when possible. Keep visual components dumb. Use Elm-inspired `model -> view -> update` for meaningful UI workflows. Use reducers for explicit state transitions. Use Effects only for external synchronization. Use memoization only for real performance needs. Prefer native forms and browser behavior. Test behavior and pure logic. Mock at the boundaries.

This is the work.
