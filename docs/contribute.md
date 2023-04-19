# 🍻 Contributing to this project

If you'd like to suggest improvements to this add-on or fix issues, you can raise a pull request or [raise an issue](https://github.com/bitbrain/beehave/issues).

## 🧪 Unit testing

This project uses [gdUnit](https://github.com/MikeSchulze/gdUnit4) to ensure code quality. Every pull request that introduces new changes, such as nodes or additional methods, must also provide some unit tests inside the `test/` folder. Make sure your test is in the correct folder:

- `test/nodes/decorators` contains decorator node tests.
- `test/nodes/composites` contains composite node tests.
- `test/` contains generic tests for Beehave.
- `test/actions` contains test actions used within tests.

You can run the unit tests by right-clicking the `test` folder and selecting `Run tests`.

## 🐝 Adding a new node

If you want to introduce a new node, raise a pull request after checking the issues tab for any discussions on new nodes. It's a great place to gather feedback before implementing a new node. Ensure that you also introduce an icon for your node that follows the color scheme:

- Utility nodes: `#C689FF`
- Leafs: `#FFB649`
- Decorators: `#46C0E1`
- Composites: `#40D29F`

Also, update the `README.md` file with the documentation for the newly introduced node.

## 📚 Adding documentation

If you're introducing a new feature or changing behavior, update the wiki accordingly. Modify the `/docs` folder inside the repository. To test your wiki locally, run the following command:
```bash
docsify serve /docs
```
> 💡 [Learn more](https://docsify.js.org/#/?id=docsify) about how to use **docsify**.

## Version management

The current `godot-3.x` branch is aimed for **Godot 3.x** while any **Godot 4.x** features should go into the `godot-4.x` branch. When raising pull requests, make sure to also raise a Godot 4 relevant version against `godot-4.x` if requested.
