import { module, test } from "qunit";
import { setupRenderingTest } from "test-app/tests/helpers";
import { tracked } from "@glimmer/tracking";
import { render, settled } from "@ember/test-helpers";
import curryComponent from "ember-curry-component";
import { getOwner } from "@ember/owner";
import { hbs } from "ember-cli-htmlbars";

const baseComponent = <template>
  <div class="one">{{@one}}</div><div class="two">{{@two}}</div>
</template>;

module("Integration | curryComponent", function (hooks) {
  setupRenderingTest(hooks);

  test("strict mode | {{#let}}", async function (assert) {
    const curriedComponent = curryComponent(
      baseComponent,
      {
        one: "one",
        two: "two",
      },
      getOwner(this),
    );

    await render(
      <template>
        {{#let curriedComponent as |MyComp|}}<MyComp />{{/let}}
      </template>,
    );

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });

  test("strict mode | access via property", async function (assert) {
    const baseComponent = <template>
      <div class="one">{{@one}}</div><div class="two">{{@two}}</div>
    </template>;
    const curriedComponent = curryComponent(
      baseComponent,
      {
        one: "one",
        two: "two",
      },
      getOwner(this),
    );

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

    const baseComponent = <template>
      <div class="one">{{@one}}</div><div class="two">{{@two}}</div>
    </template>;
    const curriedComponent = curryComponent(
      baseComponent,
      {
        one: "one",
        two: "two",
      },
      getOwner(this),
    );

    await render(<template><curriedComponent /></template>);

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });

  test("classic mode | {{#let}}", async function (assert) {
    this.curriedComponent = curryComponent(
      baseComponent,
      {
        one: "one",
        two: "two",
      },
      getOwner(this),
    );

    await render(
      hbs`{{#let this.curriedComponent as |MyComp|}}<MyComp />{{/let}}`,
    );

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });

  test("classic mode | property", async function (assert) {
    this.curriedComponent = curryComponent(
      baseComponent,
      {
        one: "one",
        two: "two",
      },
      getOwner(this),
    );

    await render(hbs`<this.curriedComponent />`);

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });

  test("dynamic arguments", async function (assert) {
    const state = new (class {
      @tracked one = "one";
      @tracked two = "two";
    })();

    this.curriedComponent = curryComponent(
      baseComponent,
      {
        get one() {
          return state.one;
        },
        get two() {
          return state.two;
        },
      },
      getOwner(this),
    );

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
        {{#let (curryComponent baseComponent args) as |MyComp|}}
          <MyComp />
        {{/let}}
      </template>,
    );

    assert.dom(".one").hasText("one");
    assert.dom(".two").hasText("two");
  });
});
