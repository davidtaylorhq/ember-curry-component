import { module, test } from "qunit";
import { setupRenderingTest } from "test-app/tests/helpers";
import { tracked, cached } from "@glimmer/tracking";
import { render, settled } from "@ember/test-helpers";
import curryComponent from "ember-curry-component";
import { hbs } from "ember-cli-htmlbars";
import Component from "@glimmer/component";
import { TrackedAsyncData } from "ember-async-data";
import DemoComponent from "./demo-component";

module("Integration | curryComponent", function (hooks) {
  setupRenderingTest(hooks);

  test("strict mode | {{#let}}", async function (assert) {
    const curriedComponent = curryComponent(DemoComponent, {
      one: "one",
      two: "two",
    });

    await render(
      <template>
        {{#let curriedComponent as |MyComp|}}<MyComp />{{/let}}
      </template>,
    );

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });

  test("strict mode | access via property", async function (assert) {
    const curriedComponent = curryComponent(DemoComponent, {
      one: "one",
      two: "two",
    });

    const state = {
      curriedComponent,
    };

    await render(<template><state.curriedComponent /></template>);

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });

  test.skip("strict mode | access local", async function (assert) {
    // Seems that glimmer doesn't accept CurriedValue components on local
    // scope references in strict mode templates.

    const curriedComponent = curryComponent(DemoComponent, {
      one: "one",
      two: "two",
    });

    await render(<template><curriedComponent /></template>);

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });

  test("classic mode | {{#let}}", async function (assert) {
    this.curriedComponent = curryComponent(DemoComponent, {
      one: "one",
      two: "two",
    });

    await render(
      hbs`{{#let this.curriedComponent as |MyComp|}}<MyComp />{{/let}}`,
    );

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });

  test("classic mode | property", async function (assert) {
    this.curriedComponent = curryComponent(DemoComponent, {
      one: "one",
      two: "two",
    });

    await render(hbs`<this.curriedComponent />`);

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });

  test("dynamic arguments", async function (assert) {
    const state = new (class {
      @tracked one = "one";
      @tracked two = "two";
    })();

    this.curriedComponent = curryComponent(DemoComponent, {
      get one() {
        return state.one;
      },
      get two() {
        return state.two;
      },
    });

    await render(hbs`<this.curriedComponent />`);

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");

    state.one = "uno";
    state.two = "dos";

    await settled();

    assert.dom(".one").hasText("uno");
    assert.dom(".two").hasText("dos");
  });

  test("as a helper", async function (assert) {
    const args = {
      one: "one",
      two: "two",
    };

    await render(
      <template>
        {{#let (curryComponent DemoComponent args) as |MyComp|}}
          <MyComp />
        {{/let}}
      </template>,
    );

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });

  test("passthrough all args - with getter", async function (assert) {
    class Wrapper extends Component {
      get curriedComponent() {
        return curryComponent(DemoComponent, this.args);
      }
      <template><this.curriedComponent /></template>
    }

    await render(<template><Wrapper @one="one" @two="two" /></template>);

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });

  test("passthrough all args - with helper", async function (assert) {
    class Wrapper extends Component {
      <template>
        {{#let (curryComponent DemoComponent this.args) as |MyComp|}}
          <MyComp />
        {{/let}}
      </template>
    }

    await render(<template><Wrapper @one="one" @two="two" /></template>);

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });

  test("lazy component", async function (assert) {
    class Lazy extends Component {
      @cached
      get componentPromise() {
        return new TrackedAsyncData(this.args.asyncComponent());
      }

      get curriedComponent() {
        if (this.componentPromise.isResolved) {
          return curryComponent(this.componentPromise.value, this.args);
        }
      }

      <template>
        {{#if this.curriedComponent}}
          <this.curriedComponent />
        {{else}}
          Loading...
        {{/if}}
      </template>
    }

    const asyncComponent = async () => DemoComponent; // Could be an async import

    await render(
      <template>
        <Lazy @asyncComponent={{asyncComponent}} @one="one" @two="two" />
      </template>,
    );

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });
});
