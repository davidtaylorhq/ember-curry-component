import { createComputeRef, createConstRef } from '@glimmer/reference';
import { createCapturedArgs, curry, EMPTY_POSITIONAL } from '@glimmer/runtime';
import { dict } from '@glimmer/util';
import * as vm from '@glimmer/vm';

// CurriedType only made available in vm from Ember 5.6.0. Fallback to hardcoded value.
const ComponentCurriedType = vm.CurriedType?.Component || 0;

/**
 * Curry a component with named arguments.
 *
 * @param {Component} componentKlass - The component class to curry
 * @param {Object} namedArgs - Named arguments to curry the component with. The set of keys must be static, but the values can be dynamic (e.g. getters, or a Proxy)
 * @param {Owner} owner - The current application instance
 */
export default function curryComponent(componentKlass, namedArgs, owner) {
  let namedDict = dict();

  for (const key of Object.keys(namedArgs)) {
    namedDict[key] = createComputeRef(() => namedArgs[key]);
  }

  return curry(
    ComponentCurriedType,
    componentKlass,
    owner,
    createCapturedArgs(namedDict, EMPTY_POSITIONAL),
    false,
  );
}
