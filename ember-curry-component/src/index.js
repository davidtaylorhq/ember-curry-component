import { createComputeRef } from '@glimmer/reference';
import { createCapturedArgs, curry, EMPTY_POSITIONAL } from '@glimmer/runtime';
import { setHelperManager, capabilities } from '@ember/helper';

const ComponentCurriedType = 0;

const CACHE = new WeakMap();

/**
 * Curry a component with named arguments.
 *
 * @param {Component} componentKlass - The component class to curry
 * @param {Object} namedArgs - Named arguments to curry the component with. The set of keys must be static, but the values can be dynamic (e.g. getters, or a Proxy)
 * @param {ApplicationInstance} owner - The owner to use for the curried component

 */
export default function curryComponent(componentKlass, namedArgs, owner) {
  if (!namedArgs || !componentKlass || !owner) {
    throw new Error(
      'curryComponent requires a component class, named arguments, and an owner',
    );
  }

  let componentCache = CACHE.get(componentKlass);
  if (componentCache?.has(namedArgs)) {
    return componentCache.get(namedArgs);
  }

  const argRefsProxy = new Proxy(namedArgs, {
    get(target, prop) {
      return createComputeRef(() => target[prop]);
    },
  });

  const result = curry(
    ComponentCurriedType,
    componentKlass,
    owner,
    createCapturedArgs(argRefsProxy, EMPTY_POSITIONAL),
    false,
  );

  if (!componentCache) {
    componentCache = new WeakMap();
    CACHE.set(componentKlass, componentCache);
  }

  componentCache.set(namedArgs, result);

  return result;
}

/**
 * Like the default function helper manager,
 * but also passes the owner as a final argument.
 */
class CurryComponentHelperManager {
  capabilities = capabilities('3.23', {
    hasValue: true,
    hasDestroyable: false,
    hasScheduledEffect: false,
  });

  constructor(owner) {
    this.owner = owner;
  }

  createHelper(fn, args) {
    return { fn, args };
  }

  getValue({ fn, args }) {
    return fn(...args.positional, this.owner);
  }
}

setHelperManager(
  (owner) => new CurryComponentHelperManager(owner),
  curryComponent,
);
