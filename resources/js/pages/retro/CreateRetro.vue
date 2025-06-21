<script setup lang="ts">
import { store } from '@/actions/App/Http/Controllers/RetroController';
import InputError from '@/components/InputError.vue';
import RetroLayout from '@/layouts/retro/RetroLayout.vue';
import { useForm } from '@inertiajs/vue3';
import { Rocket } from 'lucide-vue-next';

const form = useForm({
    name: '',
    creator_name: '',
});

function submit() {
    form.submit(store());
}
</script>

<template>
    <RetroLayout>
        <div class="flex min-h-[calc(100vh-16rem)] items-center justify-center px-4">
            <div class="w-full max-w-lg">
                <!-- Main Card Container -->
                <div class="border-2 border-black shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] rounded-lg overflow-hidden">
                    <!-- Yellow Header Section -->
                    <div class="bg-yellow-400 p-6 border-b-2 border-black">
                        <h1 class="text-2xl font-bold tracking-tight text-black sm:text-3xl flex items-center gap-2">
                            <span>🚀</span>
                            <span>Create a new retrospective</span>
                        </h1>
                        <p class="mt-2 text-black/80 font-medium">
                            Let's set up your next team feedback session.
                        </p>
                    </div>
                    
                    <!-- White Form Section -->
                    <div class="bg-white p-6">
                        <form @submit.prevent="submit" class="space-y-6">
                            <!-- Retrospective Name Field -->
                            <div class="space-y-2">
                                <label for="title" class="block font-bold text-black">
                                    Retrospective Name <span class="text-red-500">*</span>
                                </label>
                                <input
                                    id="title"
                                    v-model="form.name"
                                    type="text"
                                    placeholder="e.g., Sprint 24 Review"
                                    class="w-full px-4 py-2 border-2 border-black rounded-md placeholder:text-gray-500 focus:border-yellow-400 focus:ring-2 focus:ring-yellow-400 focus:outline-none transition-colors"
                                />
                                <InputError :message="form.errors.name" />
                            </div>
                            
                            <!-- Your Name Field -->
                            <div class="space-y-2">
                                <label for="creator_name" class="block font-bold text-black">
                                    Your Name <span class="text-red-500">*</span>
                                </label>
                                <input
                                    id="creator_name"
                                    v-model="form.creator_name"
                                    type="text"
                                    placeholder="e.g., John Doe"
                                    class="w-full px-4 py-2 border-2 border-black rounded-md placeholder:text-gray-500 focus:border-yellow-400 focus:ring-2 focus:ring-yellow-400 focus:outline-none transition-colors"
                                />
                                <InputError :message="form.errors.creator_name" />
                                <p class="text-sm font-medium text-black/60">
                                    You'll be the moderator for this retrospective
                                </p>
                            </div>
                            
                            <!-- Submit Button -->
                            <div class="pt-4">
                                <button
                                    type="submit"
                                    class="w-full flex items-center justify-center gap-2 px-6 py-3 bg-yellow-400 text-black font-bold border-2 border-black rounded-md shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] transition-all hover:translate-x-[4px] hover:translate-y-[4px] hover:shadow-none hover:bg-yellow-300"
                                >
                                    <Rocket class="h-5 w-5" />
                                    <span>Create Retrospective</span>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </RetroLayout>
</template>
