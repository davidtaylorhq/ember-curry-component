// Negative template cases. Kept apart from the positive ones because the
// `@glint-expect-error` directives below make glint swallow unrelated errors in
// whichever file they live in.

import curryComponent from "ember-curry-component";
import { args, DemoOptional, DemoRequired, NoElement } from "./fixtures";

// Case 16 — a wrong-typed @arg is rejected.
export const WrongArg = <template>
  {{#let (curryComponent DemoOptional args) as |Curried|}}
    {{! @glint-expect-error: @one must be a string }}
    <Curried @one={{123}} />
  {{/let}}
</template>;

// Case 17 — splattributes on a component with no root element are rejected.
export const IllegalAttr = <template>
  {{#let (curryComponent NoElement args) as |Curried|}}
    {{! @glint-expect-error: NoElement has no root element for splattributes }}
    <Curried class="nope" />
  {{/let}}
</template>;

// Case 18b — omitting the required arg at the invocation site is rejected.
export const RequiredArgOmitted = <template>
  {{#let (curryComponent DemoRequired args) as |Curried|}}
    {{! @glint-expect-error: @name is still required at the invocation site }}
    <Curried />
  {{/let}}
</template>;
