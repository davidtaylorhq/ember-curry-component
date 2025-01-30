# ember-curry-component

Like Ember's builtin `(component)` helper, but with dynamic arguments, and JS compatibility.

## Installation

```
ember install ember-curry-component
```

## Usage

### Simple static arguments

```gjs
import Component from "@glimmer/component";
import { getOwner } from "@ember/owner";
import curryComponent from "ember-curry-component";
import SomeOtherComponent from "./some-other-component";

class MyComponent extends Component {
  get curriedComponent(){
    const args = {
      name: "David"
    };
    return curryComponent(SomeOtherComponent, args, getOwner(this))
  }

  <template>
    <this.curriedComponent />
  </template>
}
```

### Reactive arguments (option 1: per-argument reactivity)

```gjs
import Component from "@glimmer/component";
import { getOwner } from "@ember/owner";
import curryComponent from "ember-curry-component";
import SomeOtherComponent from "./some-other-component";

class MyComponent extends Component {
  @tracked name = "David";

  get curriedComponent() {
    const instance = this;
    const args = {
      get name() {
        return instance.name;
      }
    };
    return curryComponent(SomeOtherComponent, args, getOwner(this));
  }

  <template>
    <this.curriedComponent />
  </template>
}
```
When `this.name` is reassigned, the `@name` argument on the curried component will be invalidated. The `curriedComponent` getter will not be re-evaluated.

### Reactive arguments (option 2: rerender entire component)

```gjs
import Component from "@glimmer/component";
import { getOwner } from "@ember/owner";
import curryComponent from "ember-curry-component";
import SomeOtherComponent from "./some-other-component";

class MyComponent extends Component {
  @tracked name = "David";

  get curriedComponent(){
    const args = {
      name: this.name
    };
    return curryComponent(SomeOtherComponent, args, getOwner(this));
  }

  <template>
    <this.curriedComponent />
  </template>
}
```
When `this.name` is reassigned, the `curriedComponent` getter will be invalidated, and the curried component will be completely rerendered.

### As a helper

In `.gjs`/`.gjs` files, the curryComponent helper can be used directly in a template. In this case, the owner does not need to be passed explicitly.

```gjs
import SomeOtherComponent from "./some-other-component";

const args = { name: "david" }

<template>
  {{#let (curryComponent MyComponent args) as |curriedComponent|}}
    <curriedComponent />
  {{/let}}
</templates>
```

### Caveats

In `<template>`, curried components cannot be rendered from the local scope. This will fail:

```gjs
// Do not copy!
const curried = curryComponent(MyComponent, args, owner)
<template><curried /></template>
```
You must wrap the invocation in `{{#let}}` instead:
```gjs
// Do not copy!
const curried = curryComponent(MyComponent, args, owner)
<template>
  {{#let curried as |myComponent|}}
    <myComponent />
  {{/let}}
</template>
```

## Contributing

See the [Contributing](CONTRIBUTING.md) guide for details.

## License

This project is licensed under the [MIT License](LICENSE.md).
