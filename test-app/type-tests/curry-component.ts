import templateOnly from "@ember/component/template-only";
import type Owner from "@ember/owner";
import Component from "@glimmer/component";
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

// Case 1 — direct 3-arg call, all-optional class → returns the same type.
expectTypeOf(curryComponent(DemoOptional, {}, owner)).toEqualTypeOf<
  typeof DemoOptional
>();

// Case 2 — required-arg class is ACCEPTED (unconstrained <C> must admit it).
expectTypeOf(curryComponent(DemoRequired, { name: "x" }, owner)).toEqualTypeOf<
  typeof DemoRequired
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

// Case 9 — 2-arg call (template overload; owner omitted) type-checks.
expectTypeOf(curryComponent(DemoOptional, {})).toEqualTypeOf<
  typeof DemoOptional
>();

// Case 10 — owner is required in the 3-arg (JS) form: passing `undefined`
// matches neither overload (the 2-arg overload takes exactly two arguments).
// @ts-expect-error - owner must be an Owner, not undefined
curryComponent(DemoOptional, {}, undefined);

// Case 11 — negative: omitting namedArgs (1-arg call) is rejected.
// @ts-expect-error - namedArgs is required
curryComponent(DemoOptional);
