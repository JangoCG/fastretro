<script setup lang="ts">
import type { HTMLAttributes } from 'vue';

defineOptions({
    inheritAttrs: false,
});

interface Props {
    className?: HTMLAttributes['class'];
}

defineProps<Props>();
</script>

<template>
    <svg
        :class="className"
        v-bind="$attrs"
        viewBox="0 0 200 50"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
    >
        <!-- Logo Icon - Modern circular arrows representing retrospective/cycle -->
        <g transform="translate(10, 10)">
            <!-- Outer circle with gradient -->
            <defs>
                <linearGradient id="logoGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" style="stop-color:#8b5cf6;stop-opacity:1" />
                    <stop offset="100%" style="stop-color:#3b82f6;stop-opacity:1" />
                </linearGradient>
            </defs>
            
            <!-- Circular arrows forming a cycle -->
            <path
                d="M 15 5 Q 25 5 25 15 Q 25 25 15 25"
                stroke="url(#logoGradient)"
                stroke-width="3"
                stroke-linecap="round"
                fill="none"
            />
            <path
                d="M 15 25 Q 5 25 5 15 Q 5 5 15 5"
                stroke="url(#logoGradient)"
                stroke-width="3"
                stroke-linecap="round"
                fill="none"
                opacity="0.6"
            />
            
            <!-- Arrow heads -->
            <path
                d="M 23 12 L 25 15 L 21 16"
                stroke="url(#logoGradient)"
                stroke-width="3"
                stroke-linecap="round"
                stroke-linejoin="round"
                fill="none"
            />
            <path
                d="M 7 18 L 5 15 L 9 14"
                stroke="url(#logoGradient)"
                stroke-width="3"
                stroke-linecap="round"
                stroke-linejoin="round"
                fill="none"
                opacity="0.6"
            />
            
            <!-- Center dot -->
            <circle cx="15" cy="15" r="2" fill="url(#logoGradient)" />
        </g>
        
        <!-- Text Logo -->
        <text x="50" y="32" font-family="Inter, system-ui, sans-serif" font-size="24" font-weight="700" fill="#1a1a1a">
            Simple
            <tspan fill="url(#logoGradient)">Retro</tspan>
        </text>
    </svg>
</template>