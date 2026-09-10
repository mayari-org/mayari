<div align="center">
    <h1>
        <img height="150" src="./docs/public/mayari.png" alt="Mayari">
    </h1>
    <h3>
        An Adaptive Luau Web Backend Framework.
    </h3>
    <a href="https://luaupm.com/package?name=mayari%2Fcore"><img alt="LPM" src="https://img.shields.io/badge/lpm-mayari/core-e61048?style=for-the-badge&labelColor=000"></a>
    <a href="https://mayari-org.github.io/docs/"><img alt="Mayari Documentation" src="https://img.shields.io/badge/mayari-documentation-292928?style=for-the-badge&labelColor=000"></a>
    <a href="https://github.com/mayari-org/mayari/actions/workflows/ci.yml"><img alt="CI Status" src="https://img.shields.io/github/actions/workflow/status/mayari-org/mayari/ci.yml?style=for-the-badge&label=CI&labelColor=000"></a>
</div>

###

# Getting Started

The fastest way to get a Mayari project running is by using our cli tool

## Prerequisites

Make sure you have the following installed:

- `A Package Manager:`
Visit Ember's official [`GitHub repo`](https://github.com/ember-luau/ember/releases) and get the binary on the releases, or if you are currently using Linux or macOS, you can instead run this:

```bash
curl -fsSL https://mayari-org.github.io/docs/install-ember.sh | sh
```

## Using the CLI

We created a CLI tool that handle project boilerplates for you. It sets up your folders, configures your package manager, and creates sample routes automatically.

Open your terminal and run:

```bash
embx mayari-org/mayari-cli create
```

Once executed, the CLI will prompt you to choose a project type:

- **`Standard:`** Scaffolds a standard backend project.
- **`Bare:`** Scaffolds a bare project, mainly used for library development.

Then run:

```bash
embr run dev
```

To start your development (only for standard project).
