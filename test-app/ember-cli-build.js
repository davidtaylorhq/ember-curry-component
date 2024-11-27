"use strict";

const EmberApp = require("ember-cli/lib/broccoli/ember-app");

module.exports = function (defaults) {
  let app = new EmberApp(defaults, {
    autoImport: {
      watchDependencies: ["ember-curry-component"],
    },
  });

  const { maybeEmbroider } = require("@embroider/test-setup");
  return maybeEmbroider(app);
};
