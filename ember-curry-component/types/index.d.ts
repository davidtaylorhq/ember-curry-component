import type Owner from '@ember/owner';
import type { WithBoundArgs } from '@glint/template';
import type {
  AnyFunction,
  DirectInvokable,
  Invokable,
  NamedArgNames,
} from '@glint/template/-private/integration';

/**
 * Curried args become optional at the invocation site, as with `{{component}}`,
 * and remain overridable. A component type that cannot be introspected
 * (`unknown`, `any`, a plain `object`) passes through unchanged.
 */
type Curried<C, A> =
  C extends Invokable<AnyFunction>
    ? WithBoundArgs<C, Extract<keyof A, NamedArgNames<C>>>
    : C;

/**
 * Curry a component with a set of named arguments, returning a new component
 * that renders the original with those arguments pre-bound.
 *
 * In a template the owner is supplied by the helper manager; in JavaScript it
 * must be passed explicitly.
 */
declare const curryComponent: (<C, A extends object>(
  componentKlass: C,
  namedArgs: A,
  owner: Owner,
) => Curried<C, A>) &
  DirectInvokable<
    <C, A extends object>(componentKlass: C, namedArgs: A) => Curried<C, A>
  >;

export default curryComponent;
