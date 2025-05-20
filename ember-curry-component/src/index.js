import { createComputeRef } from '@glimmer/reference';
import { createCapturedArgs, curry, EMPTY_POSITIONAL } from '@glimmer/runtime';
import { dict } from '@glimmer/util';
import * as vm from '@glimmer/vm';
import { setHelperManager, capabilities } from '@ember/helper';

// CurriedType only made available in vm from Ember 5.6.0. Fallback to hardcoded value.
const ComponentCurriedType = vm.CurriedType?.Component || 0;

// Based on NamedArgsProxy in @glimmer/manager
class CurryComponentArgsProxy {
  constructor(namedArgs) {
    this.namedArgs = namedArgs;
  }

  get(_, prop) {
    return createComputeRef(() => Reflect.get(this.namedArgs, prop));
  }

  has(target, prop) {
    return Reflect.has(this.namedArgs, prop);
  }

  ownKeys() {
    return Reflect.ownKeys(this.namedArgs);
  }

  isExtensible() {
    return false;
  }

  getOwnPropertyDescriptor(_, prop) {
    // args proxies do not have real property descriptors, so you should never need to call getOwnPropertyDescriptor yourself. This code exists for enumerability, such as in for-in loops and Object.keys()
    if (Reflect.has(this.namedArgs, prop)) {
      return {
        enumerable: true,
        configurable: true,
      };
    }
  }
}

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

  const argsProxy = new Proxy({}, new CurryComponentArgsProxy(namedArgs));

  return curry(
    ComponentCurriedType,
    componentKlass,
    owner,
    createCapturedArgs(argsProxy, EMPTY_POSITIONAL),
    false,
  );
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
