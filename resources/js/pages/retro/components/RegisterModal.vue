<script setup lang="ts">
import InputError from '@/components/InputError.vue';
import { useForm } from '@inertiajs/vue3';
import { onMounted } from 'vue';

const props = defineProps<{ retroId: string }>();

const form = useForm({
    name: '',
});

function registerUser() {
    form.post(route('retro.join', props.retroId));
}

// Focus the input when modal is mounted
onMounted(() => {
    const input = document.getElementById('name') as HTMLInputElement;
    if (input) {
        input.focus();
    }
});
</script>

<template>
    <!-- Modal Backdrop -->
    <div class="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm">
        <!-- Modal Container -->
        <div class="fixed inset-0 z-50 flex items-center justify-center p-4">
            <!-- Modal Content -->
            <div class="w-full max-w-md border-4 border-black bg-white rounded-xl shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] overflow-hidden">
                <!-- Header -->
                <div class="bg-yellow-400 border-b-4 border-black p-6">
                    <h2 class="text-2xl font-bold text-black flex items-center gap-2">
                        <span>👋</span>
                        <span>Join the Retro</span>
                    </h2>
                    <p class="mt-2 text-black/80 font-medium">
                        Enter a nickname so your colleagues know who you are
                    </p>
                </div>

                <!-- Form -->
                <form @submit.prevent="registerUser" class="p-6">
                    <div class="space-y-4">
                        <div class="space-y-2">
                            <label for="name" class="block text-sm font-bold text-black">
                                Your Name <span class="text-red-500">*</span>
                            </label>
                            <input
                                id="name"
                                type="text"
                                required
                                autofocus
                                autocomplete="name"
                                v-model="form.name"
                                placeholder="e.g., John Doe or Master of Deployments"
                                class="w-full px-4 py-3 text-lg border-2 border-black rounded-lg placeholder:text-gray-500 focus:ring-2 focus:ring-yellow-400 focus:border-yellow-400 focus:outline-none transition-colors"
                                :disabled="form.processing"
                            />
                            <InputError :message="form.errors.name" />
                        </div>

                        <!-- Fun suggestions -->
                        <div class="text-sm text-black/60 font-medium">
                            💡 Pro tip: Use a fun nickname to keep things light!
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <div class="mt-6">
                        <button
                            type="submit"
                            class="w-full flex items-center justify-center gap-2 px-6 py-3 bg-yellow-400 text-black font-bold text-lg border-2 border-black rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[4px] hover:translate-y-[4px] transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                            :disabled="form.processing || !form.name.trim()"
                        >
                            <span>🚀</span>
                            <span>{{ form.processing ? 'Joining...' : 'Join Retrospective' }}</span>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</template>

<style scoped></style>
