# PC Builder Expert System

An AI-powered PC building consultation system. It uses a Prolog-based expert system (hybrid forward/backward chaining) for reasoning and a React + Vite frontend for the UI.

## Overview

The system analyzes user requirements (budget, usage, preferences) and returns personalized PC build recommendations with confidence scores and an explanation trace.

## Documentation

- API specification: [`openAPI.yml`](./openAPI.yml)
- Detailed "How it works" guide: [`PCBuilderExpertSystem.md`](./PCBuilderExpertSystem.md)

## Architecture

- Backend: SWI-Prolog expert system with a simple HTTP server
- Frontend: React (Vite)

## Prerequisites

- SWI-Prolog (9.x recommended)
- Node.js (v16+)
- Homebrew (or any similar package manager)

Install SWI-Prolog: download the .dmg/.pkg from the SWI-Prolog site and install.

Add SWI-Prolog to your PATH (example for zsh):

```bash
echo 'export PATH="/Applications/SWI-Prolog.app/Contents/MacOS:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Verify SWI-Prolog:

```bash
swipl --version
```

Install Node.js (example using Homebrew):

```bash
brew install node
```

## Installation & Running

From the project root, run the backend and frontend in separate terminals.

1. Start the backend (Prolog server):

```bash
cd backend
swipl -s server.pl -g "server" -t halt
```

Expected output:

```text
=== PC Builder Expert System ===
Server running on http://localhost:8080

Ready!
```

1. Start the frontend:

```bash
cd frontend
npm install
npm run dev
```

Vite will typically serve at `http://localhost:5173`.

## Open the Application

Open your browser at:

```text
http://localhost:5173
```

## Usage (UI flow)

1. Start the expert consultation
2. Choose budget (Budget / Mid-Range / High-End / Enthusiast)
3. Select primary usage (Office / Gaming / Programming / Content Creation)
4. If applicable, choose gaming level (1080p / 1440p / 4K)
5. Optionally select CPU preference (Intel / AMD / None)
6. Choose RGB importance (Very Important / Nice to Have / Don't Care)
7. Select cooling preference (AIO Liquid / Air Cooling / Either)
8. View results: component list with build-quality confidence scores, explanations, and reasoning trace

## Project Structure

The repository now contains a clear separation between the Prolog backend and the React frontend. Key files and folders are listed below.

```text
pc-builder-expert-system/
├── backend/                     # SWI-Prolog expert system
│   ├── server.pl                # HTTP server and main entry
│   ├── kb.pl                    # Knowledge base (components, facts)
│   ├── rules.pl                 # Inference rules
│   ├── chaining.pl              # Forward/backward chaining orchestration
│   ├── scoring.pl               # Component scoring logic
│   ├── recommend.pl             # Build recommendation driver
│   ├── confidence.pl            # Confidence calculation helpers
│   ├── explanations.pl          # Explanation / rationale generation
│   ├── handlers.pl              # HTTP handlers (endpoints)
│   ├── trace.pl                 # Trace capture utilities
│   ├── state.pl                 # Server state and session helpers
│   └── tiers.pl                 # Budget/tiers definitions

├── frontend/                    # React + Vite frontend
│   ├── package.json
│   ├── vite.config.js
│   └── src/
│       ├── App.jsx              # Main React app wiring
│       ├── main.jsx             # Vite entry point
│       ├── index.css
│       ├── assets/              # Images and static assets
│       └── components/
│           ├── pages/           # Page-level components
│           │   ├── HomePage.jsx
│           │   ├── QuestionsPage.jsx
│           │   ├── GeneratingPage.jsx
│           │   └── ResultsPage.jsx
│           └── shared/          # Reusable UI pieces
│               ├── Badge.jsx
│               ├── ComponentCard.jsx
│               ├── ExpertCard.jsx
│               ├── OptionCard.jsx
│               ├── PageLayout.jsx
│               └── SpecBox.jsx

├── openAPI.yml                  # API specification for backend endpoints
├── PCBuilderExpertSystem.md     # Detailed "How it works" guide
└── README.md
```

## Troubleshooting

- Backend won't start: check port availability and running processes:

```bash
lsof -i :8080
kill -9 <PID>
```

- Frontend can't connect to backend: ensure the backend is running on port 8080 and that `API_URL` in the frontend matches the backend port. Verify CORS settings in `server.pl`.

Built with: SWI-Prolog • React • Vite
