# Contributing to Fast Retro

We love your input! We want to make contributing to Fast Retro as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## 🚀 Quick Start for Contributors

1. **Fork the repo** and create your branch from `main`
2. **Set up your development environment** (see [README.md](README.md))
3. **Make your changes** and add tests if applicable
4. **Ensure your code follows our standards** (run linting and tests)
5. **Create a pull request** with a clear description

## 🛠️ Development Process

We use GitHub to host code, track issues and feature requests, and accept pull requests.

### Setting Up Development Environment

```bash
# 1. Fork and clone the repository
git clone https://github.com/YOUR_USERNAME/simple-retro-vue.git
cd simple-retro-vue

# 2. Install dependencies
composer install
npm install

# 3. Set up environment
cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate --seed

# 4. Start development
composer dev
```

### Code Style and Standards

We maintain high code quality standards. Please ensure your contributions follow these guidelines:

#### Backend (PHP/Laravel)

- Follow [PSR-12](https://www.php-fig.org/psr/psr-12/) coding standards
- Use meaningful variable and method names
- Write tests for new functionality using Pest PHP
- Use Laravel best practices and conventions

#### Frontend (Vue.js/TypeScript)

- Use Vue 3 Composition API consistently
- Follow TypeScript best practices
- Use the established component patterns
- Maintain responsive design principles
- Follow the neo-brutalist design system

#### Code Quality Checks

```bash
# Run before submitting PR
npm run lint        # ESLint with auto-fix
npm run format      # Prettier formatting
vue-tsc            # TypeScript checking
composer test      # PHP tests
```

## 📝 Pull Request Process

1. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/awesome-feature
   ```

2. **Make your changes** following our coding standards

3. **Add tests** if you're adding functionality

4. **Update documentation** if needed

5. **Commit your changes** with a clear message:
   ```bash
   git commit -m "Add awesome feature that does X"
   ```

6. **Push to your fork** and create a pull request

7. **Fill out the PR template** completely

### PR Requirements

- [ ] Code follows the project's coding standards
- [ ] Tests pass (`composer test` and frontend builds)
- [ ] Changes are documented (if applicable)
- [ ] PR description clearly explains the change
- [ ] Screenshots included for UI changes
- [ ] Breaking changes are clearly marked

## 🐛 Bug Reports

We use GitHub Issues to track bugs. Report a bug
by [opening a new issue](https://github.com/JangoCG/fastretro/issues/new?template=bug_report.md).

**Great Bug Reports** include:

- A quick summary and/or background
- Steps to reproduce (be specific!)
- What you expected would happen
- What actually happens
- Browser/OS information
- Screenshots (if applicable)

## 💡 Feature Requests

We welcome feature requests!
Please [open an issue](https://github.com/JangoCG/fastretro/issues/new?template=feature_request.md) with:

- **Use case**: Why do you need this feature?
- **Proposed solution**: How should it work?
- **Alternatives considered**: Any other approaches you've thought about?
- **Additional context**: Screenshots, mockups, etc.

## 🎨 Design Guidelines

Fast Retro uses a **neo-brutalist design system** with these principles:

### Color Palette

- **Primary**: Yellow (`#FACC15` / `yellow-400`)
- **Accent**: Black (`#000000`)
- **Success**: Green (`#22C55E` / `green-500`)
- **Error**: Red (`#EF4444` / `red-500`)
- **Background**: White (`#FFFFFF`)

### Design Principles

- **Bold borders**: 2-4px black borders on interactive elements
- **Shadow effects**: `shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]` for primary elements
- **Hover animations**: Translate and shadow changes
- **High contrast**: Black text on yellow/white backgrounds
- **Playful interactions**: Buttons move when hovered/clicked

### Component Patterns

- Cards have thick borders and shadows
- Buttons use the neo-brutalist shadow animation
- Form inputs have bold borders with yellow focus states
- Icons are bold and high contrast

## 🏷️ Issue Labels

We use these labels to organize issues:

- `bug` - Something isn't working
- `enhancement` - New feature or improvement
- `documentation` - Documentation updates
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `duplicate` - Already exists
- `wontfix` - Won't be implemented

## 💬 Community Guidelines

This project follows our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold this code.

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and community chat
- **Pull Request Reviews**: Code-specific discussions

## 🧪 Testing

### Backend Tests

```bash
composer test                    # Run all Pest PHP tests
composer test --filter=Feature   # Run feature tests only
composer test --filter=Unit      # Run unit tests only
```

### Frontend Testing

```bash
npm run build                    # Ensure production build works
vue-tsc                         # TypeScript checking
npm run lint                    # Code quality checks
```

### Manual Testing Checklist

Before submitting PR, manually test:

- [ ] Create a new retrospective
- [ ] Join as participant
- [ ] Add feedback items
- [ ] Group feedback (if in THEMING phase)
- [ ] Vote on items (if in VOTING phase)
- [ ] Test on mobile device
- [ ] Test real-time updates with multiple tabs

## 📚 Development Resources

### Key Files to Understand

- `app/Models/` - Database models and relationships
- `app/Events/` - WebSocket broadcasting events
- `resources/js/pages/` - Vue.js page components
- `resources/js/layouts/` - Layout components
- `resources/js/composables/` - Shared reactive logic

### Useful Commands

```bash
# Generate TypeScript types from Laravel models
npm run typegen


# Watch for file changes
npm run dev

# Reset database
php artisan migrate:fresh --seed
```

## ❓ Questions?

Don't hesitate to ask questions! You can:

- Open a [GitHub Discussion](https://github.com/JangoCG/fastretro/discussions)
- Comment on an existing issue
- Reach out to maintainers

Thank you for contributing to Fast Retro! 🎉
