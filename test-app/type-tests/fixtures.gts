import Component from "@glimmer/component";

// Fixture: a component whose args are all optional.
export class DemoOptional extends Component<{
  Args: { one?: string; two?: string };
  Element: HTMLDivElement;
  Blocks: { default: [] };
}> {
  <template>
    <div ...attributes>{{@one}}{{@two}}{{yield}}</div>
  </template>
}

// Fixture: a component with a REQUIRED arg (documents the return-`C` caveat).
export class DemoRequired extends Component<{
  Args: { name: string };
  Element: HTMLDivElement;
}> {
  <template>
    <div ...attributes>{{@name}}</div>
  </template>
}

// Fixture: a component with NO root element (for the illegal-attribute case).
export class NoElement extends Component<{ Args: { label?: string } }> {
  <template>{{@label}}</template>
}

export const args = { one: "a", two: "b" };
