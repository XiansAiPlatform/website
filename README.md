# Xians ACP — Marketing Website

The marketing website for **Xians Agent Control Plane (ACP)** — an open-source, MIT-licensed control plane for AI agents. Xians ACP runs the layer around your agents: tenants, prompts, conversations, webhooks, human tasks, schedules, logs, and metrics. Self-hosted, and agnostic to the agent runtime.

- Live site: <https://xiansaiplatform.github.io/website/>
- Docs: <https://xiansaiplatform.github.io/XiansAi.Docs/>
- Source: <https://github.com/XiansAiPlatform>

## About

This is a simple static website built with plain HTML, CSS, and a small amount of JavaScript — no frameworks, no build steps. It loads **Inter** and **Fraunces** from Google Fonts via a CDN link in `<head>`; all other assets are local. It can be served directly from the filesystem or with any basic web server.

## Running locally

Because the site is plain HTML/CSS with no build process, you can open it using any of the following methods:

### IDE live server

Most modern editors have a built-in or extension-based live server:

- **VS Code / Cursor** — Install the [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) extension, then right-click `index.html` and select **Open with Live Server**.
- **WebStorm / IntelliJ** — Open `index.html` and click the browser icon in the top-right corner of the editor.

### Simple HTTP servers

Run one of these from the project root:

```bash
# Python (built-in)
python3 -m http.server 8000

# Node.js (npx, no install needed)
npx serve .

# PHP (built-in)
php -S localhost:8000
```

Then open [http://localhost:8000](http://localhost:8000) in your browser.

> **Note:** Opening `index.html` directly as a `file://` URL works for layout, but the Google Fonts CDN link requires a network connection to load the custom typefaces.

## Project structure

```
.
├── index.html          # Main page
├── commercial.html     # Commercial Support detail page
├── style.css           # All styles
├── script.js           # Interactive behaviour (carousel, scroll-spy, reveal)
├── img/
│   ├── xians-logo-white.png   # Xians wordmark (white, for dark header/footer)
│   ├── 99xlogo.svg
│   ├── agents/                # Robot character illustrations
│   │   ├── green-wave.png     # Hero illustration
│   │   ├── orange.png
│   │   ├── mint.png
│   │   ├── pink-wave.png
│   │   ├── purple.png
│   │   ├── tan.png
│   │   ├── pink-clip.png
│   │   └── purple-clip.png
│   ├── activity-logs.png
│   ├── agent-store.png
│   ├── agent-studio.png
│   ├── arch.png
│   ├── business-metrics.png
│   ├── conversations.png
│   ├── hitl-tasks.png
│   ├── secrets.png
│   └── users.png
└── .github/
    └── workflows/
        └── deploy-pages.yml  # GitHub Pages deployment
```

## Design

The site uses a warm, light Scandinavian theme:

- **Palette:** warm paper (`#F6F3EC`) background, white card surfaces, dark ink (`#1B1C18`) text and header/footer, lime-green brand accent (`#A4D63C`) derived from the Xians logo.
- **Typography:** [Fraunces](https://fonts.google.com/specimen/Fraunces) (display headings) + [Inter](https://fonts.google.com/specimen/Inter) (body and UI) via Google Fonts.
- **Illustrations:** hand-drawn robot characters (`img/agents/`) from the Xians brand set, used as section accents.

## Deployment

The site is automatically deployed to GitHub Pages via the workflow in `.github/workflows/deploy-pages.yml` on pushes to the `main` branch.

## License

This marketing site is part of the open-source Xians ACP project and is MIT-licensed.

**Commercial Support** is a separate subscription service offered by [99x](https://99x.io) on top of the MIT-licensed platform. It does not change the open-source license; it adds engineering SLAs, security assessments, dependency upkeep, and supply-chain governance commitments. See [`commercial.html`](commercial.html) for details.
