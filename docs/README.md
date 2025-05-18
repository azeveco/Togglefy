# Togglefy Documentation

[![Built with Starlight](https://astro.badg.es/v2/built-with-starlight/tiny.svg)](https://starlight.astro.build)

## 🚀 Project Structure

This project uses [Astro](https://astro.build) and [Starlight](https://starlight.astro.build) to create a documentation site. The project structure is as follows:

```
.
├── public/
├── src/
│   ├── assets/
│   ├── components/
│   ├── content/
│   │   ├── docs/
│   │   │   ├── usage/
│   │   │   ├── reference/
│   └── content.config.ts
├── astro.config.mjs
├── package.json
└── tsconfig.json
```

Inside docs, there are the index, including-it and getting-started pages. These are introductory pages.

The usage folder contains more to the point documentation. Basically the README.md file, but in a more structured way.

The reference folder contains the API reference for the project. This is where you can find all the details about the project.

## 🧞 Commands

All commands are run from the root of the project, from a terminal:

| Command                   | Action                                           |
| :------------------------ | :----------------------------------------------- |
| `npm install`             | Installs dependencies                            |
| `npm run dev`             | Starts local dev server at `localhost:4321`      |
| `npm run build`           | Build your production site to `./dist/`          |
| `npm run preview`         | Preview your build locally, before deploying     |
| `npm run astro ...`       | Run CLI commands like `astro add`, `astro check` |
| `npm run astro -- --help` | Get help using the Astro CLI                     |