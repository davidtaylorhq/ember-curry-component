import { getOwner } from "@ember/owner";
import Component from "@glimmer/component";
import curryComponent from "ember-curry-component";

class DemoOptional extends Component<{
  Args: { one?: string; two?: string };
  Element: HTMLDivElement;
  Blocks: { default: [] };
}> {
  <template>
    <div ...attributes>{{@one}}{{@two}}{{yield}}</div>
  </template>
}

// A component with a REQUIRED arg (documents the return-`C` caveat).
class DemoRequired extends Component<{
  Args: { name: string };
  Element: HTMLDivElement;
}> {
  <template>
    <div ...attributes>{{@name}}</div>
  </template>
}

// A component with NO root element (for the illegal-attribute negative).
class NoElement extends Component<{ Args: { label?: string } }> {
  <template>{{@label}}</template>
}

const args = { one: "a", two: "b" };

// Case 12 — helper form: (curryComponent Demo args) with 2 positional args
// (owner injected by the manager) invoked via {{#let}}. Guards that the
// overload survives glint's resolve<T> and no "expected 3 arguments" fires.
export const HelperForm = <template>
  {{#let (curryComponent DemoOptional args) as |Curried|}}
    <Curried @one="y" class="z" />
  {{/let}}
</template>;

// Case 13 + 14 — direct-call result on a getter, invoked with a known @arg and
// element attributes (class/id) honored against the base HTMLDivElement.
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

// Case 16 — negative: a wrong-typed @arg is rejected.
export const WrongArg = <template>
  {{#let (curryComponent DemoOptional args) as |Curried|}}
    {{! @glint-expect-error: @one must be a string }}
    <Curried @one={{123}} />
  {{/let}}
</template>;

// Case 17 — negative: element attributes on a component with no root element
// are rejected (the returned type preserves the base's lack of an Element).
export const IllegalAttr = <template>
  {{#let (curryComponent NoElement args) as |Curried|}}
    {{! @glint-expect-error: NoElement has no root element for splattributes }}
    <Curried class="nope" />
  {{/let}}
</template>;

// Case 18 — a required-arg base curries fine and invokes fine WHEN the arg is
// supplied at the call site. Because the return type is `C` (curried args are
// not subtracted), the arg must still be passed here — the documented caveat.
export const RequiredArgSupplied = <template>
  {{#let (curryComponent DemoRequired args) as |Curried|}}
    <Curried @name="x" />
  {{/let}}
</template>;

// Case 18b — negative: omitting the required arg at the invocation site is
// rejected (proves the caveat: currying does not make it optional in the type).
export const RequiredArgOmitted = <template>
  {{#let (curryComponent DemoRequired args) as |Curried|}}
    {{! @glint-expect-error: @name is still required at the invocation site }}
    <Curried />
  {{/let}}
</template>;
