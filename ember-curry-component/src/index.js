import { createComputeRef, createConstRef } from '@glimmer/reference';
import { createCapturedArgs, curry, EMPTY_POSITIONAL } from '@glimmer/runtime';
import { dict } from '@glimmer/util';
import * as vm from '@glimmer/vm';

// CurriedType only made available in vm from Ember 5.6.0. Fallback to hardcoded value.
const ComponentCurriedType = vm.CurriedType?.Component || 0;

export default function curryComponent(componentKlass, namedArgs, owner) {
  let namedDict = dict();

  if (!(typeof namedArgs === 'object' && namedArgs.constructor === Object)) {
    throw 'Named arguments must be a simple object';
  }

  for (const [key, descriptor] of Object.entries(
    Object.getOwnPropertyDescriptors(namedArgs),
  )) {
    if (descriptor.get) {
      namedDict[key] = createComputeRef(() => namedArgs[key]);
    } else {
      namedDict[key] = createConstRef(namedArgs[key]);
    }
  }

  return curry(
    ComponentCurriedType,
    componentKlass,
    owner,
    createCapturedArgs(namedDict, EMPTY_POSITIONAL),
    false,
  );
}
