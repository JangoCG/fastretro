<script setup lang="ts">
import { Participant } from '@/types/model';

defineProps<{ participant: Participant; participants: Participant[] }>();
defineEmits(['startRetro']);
</script>

<template>
    <!-- Main Welcome Section -->
    <div class="border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] rounded-lg overflow-hidden mb-6">
        <div class="bg-yellow-400 p-6 border-b-2 border-black">
            <h1 class="text-2xl font-bold text-black flex items-center gap-2">
                <span>🎉</span>
                <span>Welcome to the retrospective</span>
            </h1>
            <p class="mt-2 text-black/80 font-medium">
                {{ participants.length }} participant(s) present and ready to share feedback
            </p>
        </div>
        
        <div class="bg-white p-6">
            <div class="flex flex-col sm:flex-row items-center justify-between gap-4">
                <div class="text-lg font-medium text-black">
                    Ready to start when you are!
                </div>
                <button 
                    v-if="participant?.role === 'moderator'" 
                    class="w-full sm:w-auto flex items-center justify-center gap-2 px-6 py-3 bg-yellow-400 text-black font-bold border-2 border-black rounded-md shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] transition-all hover:translate-x-[4px] hover:translate-y-[4px] hover:shadow-none hover:bg-yellow-300"
                    @click="$emit('startRetro')"
                >
                    <span>🚀</span>
                    <span>Start Retrospective</span>
                </button>
            </div>
        </div>
    </div>

    <!-- Participants Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        <div 
            v-for="(participant, index) in participants" 
            :key="participant.session_id || index" 
            class="border-2 border-black bg-white rounded-lg shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] transition-all p-6 flex flex-col items-center"
        >
            <!-- Avatar -->
            <div class="w-16 h-16 rounded-full bg-yellow-400 border-2 border-black flex items-center justify-center mb-3 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]">
                <span class="text-2xl font-bold text-black">
                    {{ participant.name.charAt(0).toUpperCase() }}
                </span>
            </div>
            
            <!-- Name -->
            <div class="text-lg font-bold text-black text-center">
                {{ participant.name }}
            </div>
            
            <!-- Role Badge -->
            <div v-if="participant.role === 'moderator'" class="mt-2 px-2 py-1 bg-black text-yellow-400 text-xs font-bold rounded border border-black flex items-center gap-1">
                <span>👑</span>
                <span>Moderator</span>
            </div>
        </div>
    </div>
</template>

<style scoped></style>
