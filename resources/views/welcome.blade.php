<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fast Retro - Open Source Retrospective Tool</title>
    <meta name="description"
          content="An open source retrospective tool for agile teams. Run effective retrospectives fast with real-time collaboration.">
    @vite(['resources/css/blade.css', 'resources/js/blade.js'])
</head>
<body class="bg-white antialiased">
<!-- Navigation -->
<nav class="relative z-50" x-data="{ open: false }">
    <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="flex items-center justify-between py-6">
            <div class="flex items-center gap-x-12">
                <a href="#" class="-m-1.5 p-1.5">
                    <span class="sr-only">Fast Retro</span>
                    <div class="flex items-center gap-2">
                        <div
                            x-data="{ size: 'md' }"
                            :class="{
                                'size-6 text-base': size === 'sm',
                                'size-8 text-[22px]': size === 'md',
                                'size-10 text-2xl': size === 'lg'
                            }"
                            class="rounded-[8px] flex bg-yellow-400 text-black border-2 border-black items-center justify-center font-bold transition-all hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-none shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]"
                        >
                            F
                        </div>
                        <span class="text-lg font-bold text-gray-900">Fast Retro</span>
                    </div>
                </a>
            </div>
            <div class="flex lg:hidden">
                <button type="button" @click="open = !open"
                        class="-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700">
                    <span class="sr-only">Open main menu</span>
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
                         x-show="!open">
                        <path stroke-linecap="round" stroke-linejoin="round"
                              d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
                    </svg>
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor"
                         x-show="open">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            <div class="hidden lg:flex lg:gap-x-12">
                <a href="#features"
                   class="text-sm font-semibold leading-6 text-gray-900 hover:text-yellow-600 transition-colors">Features</a>
                <a href="#demo"
                   class="text-sm font-semibold leading-6 text-gray-900 hover:text-yellow-600 transition-colors">Demo</a>
                <a href="https://github.com/JangoCG/fastretro" target="_blank" rel="noopener noreferrer"
                   class="text-sm font-semibold leading-6 text-gray-900 hover:text-yellow-600 transition-colors">GitHub</a>
            </div>
        </div>
    </div>

    <!-- Mobile menu -->
    <div class="lg:hidden" x-show="open" x-transition:enter="duration-300 ease-out"
         x-transition:enter-start="opacity-0 -translate-y-2" x-transition:enter-end="opacity-100 translate-y-0"
         x-transition:leave="duration-200 ease-in" x-transition:leave-start="opacity-100 translate-y-0"
         x-transition:leave-end="opacity-0 -translate-y-2">
        <!-- Mobile menu panel -->
        <div class="absolute top-full left-0 right-0 z-50 bg-white border-t border-gray-100 shadow-xl">
            <div class="px-6 py-6">
                <div class="space-y-1">
                    <a href="#features" @click="open = false"
                       class="block rounded-lg px-4 py-3 text-base font-semibold text-gray-900 hover:bg-gray-50 transition-colors">Features</a>
                    <a href="#demo" @click="open = false"
                       class="block rounded-lg px-4 py-3 text-base font-semibold text-gray-900 hover:bg-gray-50 transition-colors">Demo</a>
                    <a href="https://github.com/JangoCG/fastretro" target="_blank" rel="noopener noreferrer"
                       @click="open = false"
                       class="block rounded-lg px-4 py-3 text-base font-semibold text-gray-900 hover:bg-gray-50 transition-colors">GitHub</a>
                </div>
                <div class="mt-6 pt-6 border-t border-gray-200">
                    <a href="{{ route('retro.create') }}" @click="open = false"
                       class="block w-full rounded-lg bg-yellow-400 px-4 py-3 text-center text-base font-semibold text-black border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] transition-all">
                        Start a Retro
                    </a>
                </div>
            </div>
        </div>
    </div>
</nav>

<!-- Hero Section -->
<section class="min-h-screen bg-white flex items-center">
    <div class="w-full max-w-7xl mx-auto px-6 py-20">
        <!-- Header Content -->
        <div class="text-center space-y-8 mb-16">
            <!-- Badge -->
            <a href="https://github.com/JangoCG/fastretro" target="_blank" rel="noopener noreferrer"
               class="inline-flex items-center gap-2 bg-yellow-400 text-black px-4 py-2 rounded-full border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px] transition-all duration-200 font-bold text-sm">
                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
                    <path
                        d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" />
                </svg>
                Open Source
            </a>

            <!-- Main Headline -->
            <h1 class="text-6xl md:text-8xl font-black text-gray-900 leading-none">
                Retrospectives<br>
                made <span class="text-yellow-400 [text-shadow:4px_4px_0px_rgba(0,0,0,1)]">fast</span>
            </h1>

            <!-- Subheadline -->
            <p class="text-xl md:text-2xl text-gray-600 max-w-4xl mx-auto leading-relaxed">
                Dreading your next retro again? Cringe icebreakers, pointless fluff and going overtime (again) yeah,
                same here.
                That's why I built Fast Retro: Just two columns (good/bad), everyone presents their points,
                group similar topics together, vote on what matters most, then discuss and create action items.
                Done. No BS, no endless phases, just actionable results.
            </p>

            <!-- Key Benefits -->
            <div class="flex flex-wrap justify-center gap-6 mt-8 text-sm">
                <div
                    class="flex items-center gap-2 bg-green-100 text-green-800 px-4 py-2 rounded-full border-2 border-green-200">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    <span class="font-semibold">No account required</span>
                </div>
                <div
                    class="flex items-center gap-2 bg-blue-100 text-blue-800 px-4 py-2 rounded-full border-2 border-blue-200">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                              d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path>
                    </svg>
                    <span class="font-semibold">Data deleted nightly</span>
                </div>
            </div>

            <!-- CTA Buttons -->
            <div class="flex flex-col sm:flex-row items-center justify-center gap-4 pt-8">
                <a href="{{ route('retro.create') }}"
                   class="bg-yellow-400 text-black px-8 py-4 text-lg font-bold border-4 border-black rounded-lg shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] hover:shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:translate-x-[4px] hover:translate-y-[4px] transition-all duration-200">
                    Start a Retro Now →
                </a>
                <a href="#demo"
                   class="text-gray-900 px-8 py-4 text-lg font-semibold border-4 border-gray-900 rounded-lg hover:bg-gray-900 hover:text-white transition-all duration-200">
                    See it in action
                </a>
            </div>
        </div>

        <!-- Demo Image -->
        <div class="flex justify-center">
            <div class="max-w-5xl w-full">
                <img src="{{ asset('brainstorming.png') }}"
                     alt="Fast Retro Screenshot"
                     class="w-full h-auto rounded-3xl border-6 border-black shadow-[12px_12px_0px_0px_rgba(0,0,0,1)] hover:shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] hover:translate-x-[4px] hover:translate-y-[4px] transition-all duration-300">
            </div>
        </div>

        <!-- Quick Features -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 mt-20 text-center">
            <div class="space-y-3">
                <div
                    class="w-16 h-16 bg-yellow-400 rounded-xl border-4 border-black mx-auto flex items-center justify-center shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
                    <svg class="w-8 h-8 text-black" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <rect width="18" height="18" x="3" y="3" rx="2" />
                        <path d="M12 3v18" />
                    </svg>
                </div>
                <h3 class="text-xl font-bold text-gray-900">Two Simple Columns</h3>
                <p class="text-gray-600">Good vs Bad. That's it. No overthinking.</p>
            </div>

            <div class="space-y-3">
                <div
                    class="w-16 h-16 bg-yellow-400 rounded-xl border-4 border-black mx-auto flex items-center justify-center shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
                    <svg class="w-8 h-8 text-black" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round"
                              d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                    </svg>
                </div>
                <h3 class="text-xl font-bold text-gray-900">Group & Vote</h3>
                <p class="text-gray-600">3 votes each. Prioritize what matters.</p>
            </div>

            <div class="space-y-3">
                <div
                    class="w-16 h-16 bg-yellow-400 rounded-xl border-4 border-black mx-auto flex items-center justify-center shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
                    <svg class="w-8 h-8 text-black" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round"
                              d="M17.25 6.75 22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3-4.5 16.5" />
                    </svg>
                </div>
                <h3 class="text-xl font-bold text-gray-900">Open Source</h3>
                <p class="text-gray-600">Free, transparent, and yours to modify.</p>
            </div>
            <div class="space-y-3">
                <div
                    class="w-16 h-16 bg-yellow-400 rounded-xl border-4 border-black mx-auto flex items-center justify-center shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                         stroke="currentColor" class="w-8 h-8 text-black">
                        <path stroke-linecap="round" stroke-linejoin="round"
                              d="M12 20.25c.966 0 1.891-.427 2.545-1.171a4.535 4.535 0 001.17-2.545 4.535 4.535 0 00-1.17-2.545 4.535 4.535 0 00-2.545-1.17 4.535 4.535 0 00-2.545 1.17 4.535 4.535 0 00-1.17 2.545 4.535 4.535 0 001.17 2.545A4.535 4.535 0 0012 20.25zM12 4.5c.966 0 1.891.427 2.545 1.171a4.535 4.535 0 001.17 2.545 4.535 4.535 0 00-1.17 2.545 4.535 4.535 0 00-2.545 1.17 4.535 4.535 0 00-2.545-1.17 4.535 4.535 0 00-1.17-2.545A4.535 4.535 0 0012 4.5zM12 12.75a.75.75 0 100-1.5.75.75 0 000 1.5z" />
                    </svg>
                </div>
                <h3 class="text-xl font-bold text-gray-900">Real-time Collaboration</h3>
                <p class="text-gray-600">Everyone participates at the same time.</p>
            </div>
        </div>
    </div>
</section><!-- Features Section -->
<div id="features" class="py-24 sm:py-32 bg-gray-50">
    <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl text-center">
            <h2 class="text-base font-semibold leading-7 text-yellow-600">Everything you need</h2>
            <p class="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Better retrospectives, better
                teams</p>
            <p class="mt-6 text-lg leading-8 text-gray-600">
                Just two simple columns: "What went well?" and "What could be better?" No confusing categories,
                no analysis paralysis. Group similar feedback, vote on priorities, discuss what matters. Done.
            </p>
        </div>
        <div class="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-none">
            <dl class="grid max-w-xl grid-cols-1 gap-x-8 gap-y-16 lg:max-w-none lg:grid-cols-2">
                <!-- Feature 1 -->
                <div class="flex flex-col">
                    <dt class="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                        <div
                            class="h-10 w-10 flex items-center justify-center rounded-lg bg-yellow-400 border-2 border-black">
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                 fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                 stroke-linejoin="round" class="lucide lucide-columns2-icon lucide-columns-2">
                                <rect width="18" height="18" x="3" y="3" rx="2" />
                                <path d="M12 3v18" />
                            </svg>
                        </div>
                        Two simple columns
                    </dt>
                    <dd class="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                        <p class="flex-auto">Just "What went well?" and "What could be better?" No confusing categories
                            or endless options. Keep it simple, keep it focused.</p>
                    </dd>
                </div>

                <!-- Feature 2 -->
                <div class="flex flex-col">
                    <dt class="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                        <div
                            class="h-10 w-10 flex items-center justify-center rounded-lg bg-yellow-400 border-2 border-black">
                            <svg class="h-6 w-6 text-black" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                                 stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                      d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
                            </svg>
                        </div>
                        Smart grouping & voting
                    </dt>
                    <dd class="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                        <p class="flex-auto">No more duplicate feedback chaos. Group similar topics together, then vote
                            on what matters most with 3 votes per person. Democracy in action.</p>
                    </dd>
                </div>

                <!-- Feature 3 -->
                <div class="flex flex-col">
                    <dt class="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                        <div
                            class="h-10 w-10 flex items-center justify-center rounded-lg bg-yellow-400 border-2 border-black">
                            <svg class="h-6 w-6 text-black" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                                 stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                      d="M17.25 6.75 22.5 12l-5.25 5.25m-10.5 0L1.5 12l5.25-5.25m7.5-3-4.5 16.5" />
                            </svg>
                        </div>
                        Open source & self-hosted
                    </dt>
                    <dd class="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                        <p class="flex-auto">Your data stays on your servers. Free forever, modify as you like, no
                            vendor lock-in. Host it yourself in minutes.</p>
                    </dd>
                </div>

                <!-- Feature 4 -->
                <div class="flex flex-col">
                    <dt class="flex items-center gap-x-3 text-base font-semibold leading-7 text-gray-900">
                        <div
                            class="h-10 w-10 flex items-center justify-center rounded-lg bg-yellow-400 border-2 border-black">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5"
                                 stroke="currentColor" class="w-6 h-6 text-black">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                      d="M12 20.25c.966 0 1.891-.427 2.545-1.171a4.535 4.535 0 001.17-2.545 4.535 4.535 0 00-1.17-2.545 4.535 4.535 0 00-2.545-1.17 4.535 4.535 0 00-2.545 1.17 4.535 4.535 0 00-1.17 2.545 4.535 4.535 0 001.17 2.545A4.535 4.535 0 0012 20.25zM12 4.5c.966 0 1.891.427 2.545 1.171a4.535 4.535 0 001.17 2.545 4.535 4.535 0 00-1.17 2.545 4.535 4.535 0 00-2.545 1.17 4.535 4.535 0 00-2.545-1.17 4.535 4.535 0 00-1.17-2.545A4.535 4.535 0 0012 4.5zM12 12.75a.75.75 0 100-1.5.75.75 0 000 1.5z" />
                            </svg>
                        </div>
                        Real-time Collaboration
                    </dt>
                    <dd class="mt-4 flex flex-auto flex-col text-base leading-7 text-gray-600">
                        <p class="flex-auto">See changes as they happen. Whether it's new feedback, grouping topics, or
                            voting, everyone is always on the same page without needing to refresh.</p>
                    </dd>
                </div>
            </dl>
        </div>
    </div>
</div>

<!-- Demo Section -->
<div id="demo" class="py-24 sm:py-32">
    <div class="mx-auto max-w-7xl px-6 lg:px-8">
        <div class="mx-auto max-w-2xl text-center">
            <h2 class="text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">Ready to get started?</h2>
            <p class="mt-6 text-lg leading-8 text-gray-600">
                Create your first retrospective in seconds. <strong>No signup required</strong> - just create a retro
                and share the link.
            </p>
            <div class="mt-4 p-4 bg-yellow-50 border-2 border-yellow-200 rounded-lg">
                <p class="text-sm text-yellow-800">
                    <strong>🔒 Privacy First:</strong> All retrospective data is automatically deleted every night,
                    so your team's feedback doesn't accumulate on my servers.
                </p>
            </div>
        </div>
        <div class="mx-auto mt-10 max-w-2xl">
            <div class="flex items-center justify-center gap-x-6">
                <a href="{{ route('retro.create') }}"
                   class="rounded-md bg-yellow-400 px-6 py-3 text-base font-semibold text-black border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] transition-all">
                    Create a Retro
                </a>
            </div>
        </div>
    </div>
</div>

<!-- Footer -->
<footer class="relative bg-yellow-400 border-t-4 border-black">
    <div
        class="absolute inset-0 bg-[repeating-linear-gradient(45deg,transparent,transparent_10px,rgba(0,0,0,.03)_10px,rgba(0,0,0,.03)_20px)]"></div>
    <div class="relative mx-auto max-w-7xl px-6 py-12">
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <!-- Logo & Description -->
            <div class="space-y-4">
                <div class="flex items-center gap-2">
                    <div
                        class="size-10 rounded-[8px] flex bg-black text-yellow-400 items-center justify-center font-bold text-2xl">
                        F
                    </div>
                    <span class="text-xl font-bold text-black">Fast Retro</span>
                </div>
                <p class="text-sm text-black/80">
                    An open source retrospective tool for agile teams. No signup required, data deleted nightly for
                    privacy.
                    Run effective retrospectives fast with real-time collaboration.
                </p>
            </div>

            <!-- Quick Links -->
            <div class="space-y-4">
                <h3 class="font-bold text-black">Quick Links</h3>
                <ul class="space-y-2">
                    <li>
                        <a href="#features"
                           class="text-sm text-black/80 hover:text-black transition-colors inline-flex items-center gap-1">
                            <span>→</span> Features
                        </a>
                    </li>
                    <li>
                        <a href="#demo"
                           class="text-sm text-black/80 hover:text-black transition-colors inline-flex items-center gap-1">
                            <span>→</span> Demo
                        </a>
                    </li>
                    <li>
                        <a href="{{ route('retro.create') }}"
                           class="text-sm text-black/80 hover:text-black transition-colors inline-flex items-center gap-1">
                            <span>→</span> Start a Retro
                        </a>
                    </li>
                </ul>
            </div>

            <!-- Social & CTA -->
            <div class="space-y-4">
                <h3 class="font-bold text-black">Get Started</h3>
                <a href="{{ route('retro.create') }}"
                   class="inline-block rounded-md bg-black px-4 py-2 text-sm font-semibold text-yellow-400 border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:translate-x-[2px] hover:translate-y-[2px] transition-all">
                    Create Your First Retro
                </a>
                <div class="flex items-center gap-4 pt-2">
                    <a href="https://github.com/JangoCG/fastretro" target="_blank" rel="noopener noreferrer"
                       class="inline-block p-2 bg-white rounded-md border-2 border-black shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] transition-all">
                        <span class="sr-only">GitHub</span>
                        <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                            <path fill-rule="evenodd"
                                  d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
                                  clip-rule="evenodd" />
                        </svg>
                    </a>
                </div>
            </div>
        </div>

        <!-- Bottom Bar -->
        <div class="mt-12 pt-8 border-t-2 border-black/20">
            <div class="flex flex-col md:flex-row justify-between items-center gap-4">
                <div class="flex items-center gap-6">
                    <a href="{{ route('privacy-policy') }}"
                       class="text-sm text-black/60 hover:text-black transition-colors">Datenschutz / Privacy Policy</a>
                    <a href="{{ route('imprint') }}" class="text-sm text-black/60 hover:text-black transition-colors">Imoressum
                        / Imprint</a>
                </div>
            </div>
        </div>
    </div>
</footer>
</body>
</html>
