<script setup lang="ts">
import { CheckCircle2, Heart, Users, Trash2 } from 'lucide-vue-next';
import { Action, Participant, Retro } from '@/types/model';
import { computed, ref } from 'vue';
import { router } from '@inertiajs/vue3';
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
    AlertDialogTrigger,
} from '@/components/ui/alert-dialog';
import { Button } from '@/components/ui/button';

interface Props {
    actions: Action[];
    participants: Participant[];
    participant?: Participant;
    retro: Retro;
}

const props = defineProps<Props>();

// Count active participants
const activeParticipants = computed(() => 
    props.participants.filter(p => p.status === 'active').length
);

// Count finished participants
const finishedParticipants = computed(() => 
    props.participants.filter(p => p.status === 'finished').length
);

// Check if current participant is moderator
const isModerator = computed(() => props.participant?.role === 'moderator');

// Handle delete retro
const deleteRetro = () => {
    router.delete(route('retro.destroy', props.retro.id));
};
</script>

<template>
    <div class="flex flex-col gap-6">
        <!-- Thank You Card -->
        <div class="border-2 border-black bg-yellow-400 rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] overflow-hidden">
            <div class="text-center p-8">
                <div class="mx-auto mb-6 flex h-20 w-20 items-center justify-center rounded-full bg-black border-2 border-black shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]">
                    <Heart class="h-10 w-10 text-yellow-400" />
                </div>
                <h2 class="text-3xl font-bold text-black mb-4">
                    🎉 Retrospective Complete!
                </h2>
                <p class="text-lg text-black/80 font-medium">
                    Thanks for participating! Your feedback and insights help our team grow stronger together.
                </p>
            </div>
        </div>

        <!-- Participation Stats -->
        <div class="border-2 border-black bg-white rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
            <div class="border-b-2 border-black bg-yellow-50 p-4">
                <h3 class="flex items-center gap-2 text-xl font-bold text-black">
                    <Users class="h-6 w-6 text-black" />
                    Participation Summary
                </h3>
            </div>
            <div class="p-6">
                <div class="grid gap-4 sm:grid-cols-2">
                    <div class="flex items-center justify-between rounded-lg bg-green-100 border-2 border-black p-4 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]">
                        <span class="text-sm font-bold text-black">Total Participants</span>
                        <span class="text-3xl font-bold text-black">{{ participants.length }}</span>
                    </div>
                    <div class="flex items-center justify-between rounded-lg bg-blue-100 border-2 border-black p-4 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]">
                        <span class="text-sm font-bold text-black">Completed</span>
                        <span class="text-3xl font-bold text-black">{{ finishedParticipants }}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Actions Summary -->
        <div class="border-2 border-black bg-white rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
            <div class="border-b-2 border-black bg-yellow-50 p-4">
                <h3 class="flex items-center gap-2 text-xl font-bold text-black">
                    <CheckCircle2 class="h-6 w-6 text-black" />
                    Action Items
                </h3>
                <p class="mt-1 text-black/70 font-medium">
                    Follow up on these items to keep improving
                </p>
            </div>
            <div class="p-6">
                <div v-if="actions.length > 0" class="space-y-4">
                    <div
                        v-for="(action, index) in actions"
                        :key="action.id"
                        class="flex items-start gap-4 rounded-lg border-2 border-black bg-white p-4 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] transition-all"
                    >
                        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-yellow-400 border-2 border-black text-lg font-bold text-black shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]">
                            {{ index + 1 }}
                        </div>
                        <div class="flex-1">
                            <p class="text-black font-medium text-lg">{{ action.content }}</p>
                            <p class="mt-2 text-black/60 font-medium text-sm">
                                💡 Added by: {{ action.participant?.name || 'Unknown' }}
                            </p>
                        </div>
                    </div>
                </div>
                <div v-else class="text-center py-12">
                    <div class="w-16 h-16 bg-gray-100 border-2 border-black rounded-full flex items-center justify-center mx-auto mb-4 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]">
                        <span class="text-2xl">📝</span>
                    </div>
                    <p class="text-black font-bold text-lg">No action items created</p>
                    <p class="text-black/60 font-medium mt-1">That's okay - sometimes the discussion itself is valuable!</p>
                </div>
            </div>
        </div>

        <!-- Final Message -->
        <div class="border-2 border-black bg-yellow-100 rounded-lg shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]">
            <div class="py-8 px-6 text-center">
                <div class="text-4xl mb-4">👋</div>
                <p class="text-xl font-bold text-black mb-2">
                    See you at the next retrospective!
                </p>
                <p class="text-black/70 font-medium">
                    Remember to follow up on the action items - that's where the real improvement happens.
                </p>
            </div>
        </div>

        <!-- Delete Retro Button (Only for Moderator) -->
        <div v-if="isModerator" class="mt-8 pt-8 border-t-2 border-black/20">
            <AlertDialog>
                <AlertDialogTrigger as-child>
                    <Button
                        variant="destructive"
                        class="w-full border-2 border-black bg-red-500 hover:bg-red-600 text-white font-bold shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[4px] hover:translate-y-[4px] transition-all"
                    >
                        <Trash2 class="w-5 h-5 mr-2" />
                        Delete Retrospective
                    </Button>
                </AlertDialogTrigger>
                <AlertDialogContent class="border-2 border-black shadow-[8px_8px_0px_0px_rgba(0,0,0,1)]">
                    <AlertDialogHeader>
                        <AlertDialogTitle class="text-xl font-bold">Are you absolutely sure?</AlertDialogTitle>
                        <AlertDialogDescription class="text-black/70">
                            This action cannot be undone. This will permanently delete the retrospective 
                            <span class="font-bold text-black">"{{ retro.name }}"</span> and all related data including:
                            <ul class="mt-2 ml-4 list-disc">
                                <li>All {{ participants.length }} participants</li>
                                <li>All feedback items</li>
                                <li>All votes</li>
                                <li>All action items</li>
                            </ul>
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel class="border-2 border-black shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] transition-all">
                            Cancel
                        </AlertDialogCancel>
                        <AlertDialogAction 
                            @click="deleteRetro"
                            class="border-2 border-black bg-red-500 hover:bg-red-600 text-white shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] transition-all"
                        >
                            Yes, delete everything
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>
        </div>
    </div>
</template>

<style scoped>
/* Add any Summary specific styles here */
</style>