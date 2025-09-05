# Team Teddy Development - GitHub Templates

> 🚀 Enterprise-grade GitHub Actions workflows, quality gates, and Supabase integration for modern web applications

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Template](https://img.shields.io/badge/GitHub-Template-green.svg)](https://github.com/jejernig/team-teddy-github-template)
[![Supabase](https://img.shields.io/badge/Database-Supabase-green.svg)](https://supabase.com)
[![TypeScript](https://img.shields.io/badge/Language-TypeScript-blue.svg)](https://www.typescriptlang.org/)

## 🚀 Quick Start

### Use This Template

1. **Click "Use this template"** → **"Create a new repository"**
2. **Configure your repository** with project name and description  
3. **Clone and initialize**:

```bash
git clone https://github.com/YOUR_ORG/YOUR_PROJECT.git
cd YOUR_PROJECT

# Run setup scripts (replaces template variables)
./tools/setup-project.sh
```

### 5-Minute Setup

```bash
# 1. Install dependencies
npm install

# 2. Start local Supabase (requires Docker)
supabase start

# 3. Configure environment
cp .env.example .env.local
# Edit .env.local with your Supabase credentials

# 4. Apply database migrations  
supabase db push

# 5. Start development server
npm run dev
```

## 🎯 What's Included

### ✅ **Enterprise-Grade Quality Gates**
- **🔒 Security Scanning** - Dependency vulnerabilities, secret detection, SAST
- **🧪 Comprehensive Testing** - Unit, integration, E2E with Playwright
- **♿ Accessibility Validation** - WCAG 2.2 Level AA compliance  
- **⚡ Performance Analysis** - Bundle size, Core Web Vitals, API response times
- **📚 Documentation Quality** - README completeness, API docs, inline comments

### 🗄️ **Supabase Integration**
- **🚀 Ready-to-use Database** - PostgreSQL with migrations and Row Level Security
- **🔐 Authentication System** - User management, JWT tokens, social login
- **📁 File Storage** - Secure file uploads with CDN
- **⚡ Edge Functions** - Serverless functions with Deno runtime
- **🔄 Real-time Features** - Live updates and subscriptions

### 🛠️ **Modern Tech Stack**
- **Frontend**: React 18+, Next.js 14+, TypeScript, Tailwind CSS
- **Backend**: Supabase (PostgreSQL), Node.js
- **Testing**: Jest, Testing Library, Playwright
- **CI/CD**: GitHub Actions with automated deployments
- **Quality**: ESLint, Prettier, Husky, Commitlint

## 📋 Template Variables

When you use this template, these variables will be automatically replaced:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{PROJECT_NAME}}` | Your project name | `my-awesome-app` |
| `{{COMPANY_NAME}}` | Company name | `Team Teddy Development` |
| `{{COMPANY_EMAIL}}` | Contact email | `eric@teamteddy.net` |
| `{{GITHUB_ORG}}` | GitHub organization | `jejernig` |
| `{{COMPANY_DOMAIN}}` | Company domain | `teamteddy.net` |

## 🏃‍♂️ Getting Started

### Prerequisites

- **Node.js 20+** and npm
- **Docker** (for local Supabase development)  
- **GitHub CLI** (for secrets management)
- **Supabase Account** ([sign up free](https://app.supabase.com))

### Step 1: Create Your Project

1. **Use this template** to create a new repository
2. **Clone** your new repository locally
3. **Run setup**: `./tools/setup-project.sh`

### Step 2: Configure Supabase

1. **Create project** at [app.supabase.com](https://app.supabase.com)
2. **Get credentials** from Settings → API
3. **Configure secrets**: `./tools/configure-database-secrets.sh` 
4. **Start development**: `supabase start && npm run dev`

## 🔒 Security

- ✅ **No secrets in repository** - All sensitive data uses GitHub Secrets
- ✅ **Template variables only** - `{{VARIABLE}}` format for safe templating
- ✅ **Security scanning** - Automated dependency and code vulnerability checks
- ✅ **Secret detection** - Prevents accidental secret commits

## 📁 Repository Structure

```
team-teddy-github-template/
├── .github/
│   ├── workflows/           # CI/CD workflows
│   ├── ISSUE_TEMPLATE/      # Issue templates  
│   └── PULL_REQUEST_TEMPLATE/ # PR templates
├── tools/                   # Setup and utility scripts
├── docs/                    # Documentation
├── template.yml             # Template configuration
└── README.md               # This file
```

## 🛠️ Available Scripts

| Script | Description |
|--------|-------------|
| `./tools/setup-project.sh` | Initialize project with your variables |
| `./tools/configure-database-secrets.sh` | Set up GitHub secrets for Supabase |
| `./tools/setup-supabase-integration.sh` | Configure Supabase integration |

## 🤝 Contributing

This is a template repository for Team Teddy Development projects. For issues or improvements:

1. **Fork** this repository
2. **Create** a feature branch
3. **Make** your changes  
4. **Submit** a pull request

## 📄 License

MIT © Team Teddy Development

---

**🏗️ Built by [Team Teddy Development](https://teamteddy.net)** - Enterprise software solutions