import type Owner from "@ember/owner";

/**
 * Curry a component with a set of named arguments, returning a new component
 * that renders the original with those arguments pre-bound.
 *
 * The returned type is the *same* component type `C`, so invoking it in a
 * template type-checks against the original component's Args/Element/Blocks.
 * Note: because the curried arguments are not subtracted from the type, a
 * component with a *required* argument still requires that argument at the
 * invocation site even after it has been curried.
 */
export default function curryComponent<C>(
  componentKlass: C,
  namedArgs: object,
  owner: Owner,
): C;
/**
 * Template-helper form: `{{curryComponent Comp args}}` / `(curryComponent Comp
 * args)`. The owner is injected by the helper manager, so only two positional
 * arguments are supplied here.
 */
export default function curryComponent<C>(componentKlass: C, namedArgs: object): C;
