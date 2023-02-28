# 🍻 Contributing to this project

In case you want to suggest improvements to this addon or fix issues, feel free to raise a pull request or [raise an issue](https://github.com/bitbrain/beehave/issues)!

## 🧪 Unit testing

This project is using [gdUnit](https://github.com/MikeSchulze/gdUnit4) to ensure code quality. Every pull request that introduces new changes such as nodes or additional methods has to also provide some unit tests inside the `test/` folder. Ensure that your test is in the correct folder:

- `test/nodes/decorators` contains decorator node tests
- `test/nodes/composites` contains composite node tests
- `test/` contains generic tests for beehave
- `test/actions` contains test actions used within tests

You can run the unit tests by right-clicking the `test` folder and selecting `Run tests`.

## 🐝 Adding a new node

In case you want to introduce a new node, feel free to [raise a pull request](https://github.com/bitbrain/beehave/compare). Check the issues tab for any discussions on new nodes, as it is a great place to gather feedback before you spend time on implementing it. Ensure to also introduce an icon for your node that is following the color scheme:

- Utility nodes: `#C689FF`
- Leafs: `#FFB649`
- Decorators: `#46C0E1`
- Composites: `#40D29F`

Also ensure to update the `README.md` file with the documentation of the newly introduced node.

## 📚 Adding documentation

When introducing a new feature or changing behavior, ensure to update this wiki accordingly. In order to do so, modify the `/docs` folder inside the repository. Run the following command in order to test your wiki locally:
```bash
docsify serve /docs
```
> 💡 [Learn more](https://docsify.js.org/#/?id=docsify) about how to use **docsify**.

## Version management

The current `godot-3.x` branch is aimed for **Godot 3.x** while any **Godot 4.x** features should go into the `godot-4.x` branch. When raising pull requests, make sure to also raise a Godot 4 relevant version against `godot-4.x` if requested.
