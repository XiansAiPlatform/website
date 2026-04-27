# Xians ACP — Marketing Website

The marketing website for **Xians Agent Control Plane (ACP)** — an open-source, MIT-licensed control plane for AI agents. Xians ACP runs the layer around your agents: tenants, prompts, conversations, webhooks, human tasks, schedules, logs, and metrics. Self-hosted, and agnostic to the agent runtime.

This site introduces Xians ACP, walks through Agent Studio and the four-plane architecture, and links out to the docs and source code.

- Live site: <https://xiansaiplatform.github.io/website/>
- Docs: <https://xiansaiplatform.github.io/XiansAi.Docs/>
- Source: <https://github.com/XiansAiPlatform>

## About

This is a simple static website built with plain HTML, CSS, and a small amount of JavaScript — no frameworks, no build steps, no dependencies. It can be served directly from the filesystem or with any basic web server.

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

### Open the file directly

You can also just open `index.html` directly in a browser. Note that some icon rendering (Lucide via CDN) requires a network connection.

## Project structure

```
.
├── index.html          # Main page
├── style.css           # All styles
├── script.js           # Interactive behavior
├── img/                # Images, logos, and product screenshots
│   ├── 99xlogo.svg
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

## Deployment

The site is automatically deployed to GitHub Pages via the workflow in `.github/workflows/deploy-pages.yml` on pushes to the `main` branch.

## License

This marketing site is part of the open-source Xians ACP project and is MIT-licensed.
