import templateOnly from "@ember/component/template-only";
import type Owner from "@ember/owner";
import Component from "@glimmer/component";
import type { WithBoundArgs } from "@glint/template";
import curryComponent from "ember-curry-component";
import { expectTypeOf } from "expect-type";

const owner = {} as Owner;

// Fixture: a component whose args are all optional.
class DemoOptional extends Component<{
  Args: { one?: string; two?: string };
  Element: HTMLDivElement;
  Blocks: { default: [] };
}> {}

// Fixture: a component with a REQUIRED arg (the Finding-1 guard).
class DemoRequired extends Component<{
  Args: { name: string };
  Element: HTMLDivElement;
  Blocks: { default: [] };
}> {}

// Case 1 — the curried args are bound in the returned type, exactly as they are
// by `{{component}}`.
expectTypeOf(curryComponent(DemoOptional, { one: "a" }, owner)).toEqualTypeOf<
  WithBoundArgs<typeof DemoOptional, "one">
>();

// Case 2 — a required arg is bound too, so it is no longer required at the
// invocation site (see template-invocation.gts for the invocation itself).
expectTypeOf(curryComponent(DemoRequired, { name: "x" }, owner)).toEqualTypeOf<
  WithBoundArgs<typeof DemoRequired, "name">
>();

// Case 3 — a template-only component value is accepted.
const TemplateOnly = templateOnly<{ Args: { one?: string } }>();
curryComponent(TemplateOnly, { one: "a" }, owner);

// Case 4 — dynamic first arg typed unknown / object / any is accepted.
const dynUnknown: unknown = DemoOptional;
const dynObject: object = DemoOptional;
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const dynAny: any = DemoOptional;
curryComponent(dynUnknown, {}, owner);
curryComponent(dynObject, {}, owner);
curryComponent(dynAny, {}, owner);

// Case 5 — object literal namedArgs.
curryComponent(DemoOptional, { one: "a", two: "b" }, owner);

// Case 6 — getter-bag namedArgs.
curryComponent(
  DemoOptional,
  {
    get one() {
      return "a";
    },
  },
  owner
);

// Case 7 — a named-interface args bag (NO index signature) is accepted.
// This is the reason the param type is `object`, not `Record<string, unknown>`.
interface SomeArgs {
  one: string;
  two: string;
}
const namedInterfaceArgs = { one: "a", two: "b" } as SomeArgs;
curryComponent(DemoOptional, namedInterfaceArgs, owner);

// Case 8 — extra keys the component does not declare are accepted.
curryComponent(DemoOptional, { one: "a", nope: 123 }, owner);

// Case 9 — negative: the 2-arg call is the template form only; from JS it must
// be rejected, since the implementation throws without an owner.
// @ts-expect-error - owner is required outside of a template
curryComponent(DemoOptional, {});

// Case 10 — owner must be an Owner: `undefined` is rejected.
// @ts-expect-error - owner must be an Owner, not undefined
curryComponent(DemoOptional, {}, undefined);

// Case 11 — negative: omitting namedArgs (1-arg call) is rejected.
// @ts-expect-error - namedArgs is required
curryComponent(DemoOptional);
