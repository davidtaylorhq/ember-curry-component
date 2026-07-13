// Keep this file free of `@glint-expect-error` directives — one anywhere in a
// .gts file makes glint swallow unrelated errors in the same file, which would
// stop these cases failing when they should. Negatives: template-negatives.gts.

import { hash } from "@ember/helper";
import { getOwner } from "@ember/owner";
import Component from "@glimmer/component";
import curryComponent from "ember-curry-component";
import { args, DemoOptional, DemoRequired } from "./fixtures";

// Case 12 — helper form: 2 positional args, owner injected by the manager.
export const HelperForm = <template>
  {{#let (curryComponent DemoOptional args) as |Curried|}}
    <Curried @one="y" class="z" />
  {{/let}}
</template>;

// Case 13 + 14 — direct-call result on a getter; @args and splattributes are
// checked against the base component.
export class DirectCall extends Component {
  get curried() {
    return curryComponent(DemoOptional, args, getOwner(this)!);
  }

  <template>
    <this.curried @one="y" class="z" id="i" />
  </template>
}

// Case 15 — yielding into the curried result's default block type-checks.
export const WithBlock = <template>
  {{#let (curryComponent DemoOptional args) as |Curried|}}
    <Curried>block content</Curried>
  {{/let}}
</template>;

// Case 18 — an arg that was NOT curried is still required at the invocation site
// (`args` binds one/two, not name).
export const RequiredArgSupplied = <template>
  {{#let (curryComponent DemoRequired args) as |Curried|}}
    <Curried @name="x" />
  {{/let}}
</template>;

// Case 19 — a required arg that WAS curried is no longer required when invoked.
export const RequiredArgCurried = <template>
  {{#let (curryComponent DemoRequired (hash name="x")) as |Curried|}}
    <Curried />
  {{/let}}
</template>;

// Case 20 — a curried arg stays overridable, since invocation args win over
// curried ones.
export const CurriedArgOverridden = <template>
  {{#let (curryComponent DemoRequired (hash name="x")) as |Curried|}}
    <Curried @name="y" />
  {{/let}}
</template>;

// Case 21 — currying a curried component keeps the bindings (nesting).
export const Nested = <template>
  {{#let (curryComponent DemoRequired (hash name="x")) as |Once|}}
    {{#let (curryComponent Once (hash name="y")) as |Twice|}}
      <Twice />
    {{/let}}
  {{/let}}
</template>;
