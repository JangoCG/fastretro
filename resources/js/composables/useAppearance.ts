import { onMounted, ref } from 'vue';

type Appearance = 'light' | 'dark' | 'system';

export function updateTheme(value: Appearance) {
    if (typeof window === 'undefined') {
        return;
    }

    if (value === 'system') {
        const mediaQueryList = window.matchMedia('(prefers-color-scheme: dark)');
        const systemTheme = mediaQueryList.matches ? 'dark' : 'light';

        document.documentElement.classList.toggle('dark', systemTheme === 'dark');
    } else {
        document.documentElement.classList.toggle('dark', value === 'dark');
    }
}

const setCookie = (name: string, value: string, days = 365) => {
    if (typeof document === 'undefined') {
        return;
    }

    const maxAge = days * 24 * 60 * 60;

    document.cookie = `${name}=${value};path=/;max-age=${maxAge};SameSite=Lax`;
};

const mediaQuery = () => {
    if (typeof window === 'undefined') {
        return null;
    }

    return window.matchMedia('(prefers-color-scheme: dark)');
};

const getStoredAppearance = () => {
    if (typeof window === 'undefined') {
        return null;
    }

    return localStorage.getItem('appearance') as Appearance | null;
};

const handleSystemThemeChange = () => {
    const currentAppearance = getStoredAppearance();

    updateTheme(currentAppearance || 'system');
};

export function initializeTheme() {
    if (typeof window === 'undefined') {
        return;
    }

    // Force light mode only
    updateTheme('light');
    
    // Remove dark class to ensure light mode
    document.documentElement.classList.remove('dark');
}

const appearance = ref<Appearance>('system');

export function useAppearance() {
    onMounted(() => {
        // Always use light mode
        appearance.value = 'light';
    });

    function updateAppearance(value: Appearance) {
        // Always force light mode, ignore the value parameter
        appearance.value = 'light';

        // Store light mode in localStorage
        localStorage.setItem('appearance', 'light');

        // Store light mode in cookie
        setCookie('appearance', 'light');

        // Always update to light theme
        updateTheme('light');
    }

    return {
        appearance,
        updateAppearance,
    };
}
