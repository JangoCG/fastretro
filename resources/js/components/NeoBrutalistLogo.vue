<script setup lang="ts">
interface Props {
    size?: 'sm' | 'md' | 'lg';
    href?: string;
}

const props = withDefaults(defineProps<Props>(), {
    size: 'md',
    href: '/'
});

const sizeClasses = {
    sm: 'size-6 text-base',
    md: 'size-8 text-[22px]',
    lg: 'size-10 text-2xl'
};
</script>

<template>
    <component 
        :is="href ? 'a' : 'div'"
        :href="href"
        :class="[
            sizeClasses[size],
            'rounded-base flex bg-yellow-400 text-black border-2 border-black items-center justify-center font-bold transition-all',
            href && 'hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-none shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]'
        ]"
    >
        F
    </component>
</template>