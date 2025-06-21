<script setup lang="ts">
import NeoBrutalistLogo from '@/components/NeoBrutalistLogo.vue';
import RetroHeader from '@/components/RetroHeader.vue';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { TooltipProvider } from '@/components/ui/tooltip';
import { Participant } from '@/types/model';
import { router } from '@inertiajs/vue3';
import { Check, Copy, Crown, Send, Users } from 'lucide-vue-next';
import { computed } from 'vue';

const props = defineProps<{
    participants?: Participant[];
    participant?: Participant;
    retroId?: string;
    currentPhase?: string;
}>();

function selectParticipant(participant: Participant) {
    console.log('xx select participant', participant);
    router.post(route('retro.feedback.highlight', props.retroId), {
        participantId: participant.session_id,
    });
}

const inviteLink = computed(() => `${window.location.origin}/retro/${props.retroId}`);

const copyToClipboard = async () => {
    try {
        await navigator.clipboard.writeText(inviteLink.value);
        // You can add a toast notification here
    } catch (err) {
        console.error('Failed to copy:', err);
    }
};
</script>

<template>
    <div class="flex min-h-screen flex-col bg-gradient-to-br from-yellow-50/20 via-white to-orange-50/20">
        <TooltipProvider>
            <RetroHeader :retroId="retroId" />
        </TooltipProvider>
        <main class="flex w-full flex-1 flex-col items-stretch">
            <div class="container mx-auto flex w-full flex-col gap-4 px-2 py-4 sm:px-4">
                <div class="flex w-full flex-col gap-4 lg:flex-row">
                    <!-- Left: Main Content -->
                    <div class="flex flex-1 flex-col gap-0">
                        <slot />
                    </div>

                    <!-- Right: Sidebar Cards -->
                    <div class="flex w-full flex-col gap-4 lg:w-80" v-if="participants">
                        <Card
                            class="border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] transition-all hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]"
                        >
                            <CardHeader>
                                <CardTitle class="flex items-center gap-2">
                                    <Send class="size-5 text-black" />
                                    Invite Team Members
                                </CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div class="flex flex-col items-stretch gap-2 sm:flex-row sm:items-center">
                                    <Input :model-value="inviteLink" readonly class="min-w-0 flex-1 font-mono text-sm" />
                                    <Button
                                        variant="outline"
                                        size="icon"
                                        class="w-full shrink-0 border-2 border-black bg-yellow-400 text-black transition-colors hover:bg-yellow-300 sm:w-auto"
                                        @click="copyToClipboard"
                                    >
                                        <Copy class="size-5" />
                                    </Button>
                                </div>
                            </CardContent>
                        </Card>
                        <Card
                            class="border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] transition-all hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]"
                        >
                            <CardHeader>
                                <CardTitle class="flex items-center gap-2">
                                    <Users class="size-5 text-black" />
                                    Participants
                                </CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div class="flex flex-col gap-2">
                                    <div
                                        v-for="p in participants"
                                        :key="p.session_id"
                                        class="group relative flex cursor-pointer items-center gap-3 rounded-lg p-2 transition-all hover:bg-yellow-100 hover:pl-4"
                                        @click="selectParticipant(p)"
                                    >
                                        <Avatar class="ring-2 ring-black transition-all group-hover:ring-yellow-400">
                                            <AvatarFallback class="border-2 border-black bg-yellow-400 font-bold text-black">
                                                {{ p.name.charAt(0).toUpperCase() }}
                                            </AvatarFallback>
                                        </Avatar>
                                        <div class="flex flex-1 flex-col">
                                            <div class="flex items-center justify-between">
                                                <div class="flex items-center gap-2">
                                                    <span class="font-medium text-gray-900">{{ p.name }}</span>
                                                    <Badge v-if="p.role === 'moderator'" variant="secondary" class="h-5 gap-1">
                                                        <Crown class="h-3 w-3" />
                                                        Moderator
                                                    </Badge>
                                                </div>
                                                <div
                                                    v-if="p.status === 'finished'"
                                                    class="flex h-5 w-5 items-center justify-center rounded-full border-2 border-black bg-green-500"
                                                >
                                                    <Check class="h-3 w-3 text-white" />
                                                </div>
                                            </div>
                                            <span class="text-xs text-gray-500">{{ p.status === 'finished' ? 'Finished' : 'Active now' }}</span>
                                        </div>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>

                        <!-- Info Box for THEMING phase -->
                        <div
                            v-if="currentPhase === 'THEMING'"
                            class="overflow-hidden rounded-lg border-2 border-black bg-blue-100 shadow-[4px_4px_0px_0px_rgba(0,0,0,1)]"
                        >
                            <div class="border-b-2 border-black bg-blue-400 p-3">
                                <h3 class="flex items-center gap-2 text-sm font-bold text-black">
                                    <span>💡</span>
                                    <span>Pro Tip</span>
                                </h3>
                            </div>
                            <div class="p-3">
                                <p class="text-sm font-medium text-black">
                                    Click on any participant above to highlight their feedback items on the board!
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
        <footer class="relative mt-auto w-full border-t-4 border-black bg-yellow-400">
            <div
                class="absolute inset-0 bg-[repeating-linear-gradient(45deg,transparent,transparent_10px,rgba(0,0,0,.03)_10px,rgba(0,0,0,.03)_20px)]"
            ></div>
            <div class="relative mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
                <div class="flex flex-col items-center justify-center gap-4">
                    <!-- Brand -->
                    <div class="flex items-center gap-3">
                        <NeoBrutalistLogo :href="undefined" />
                        <span class="text-lg font-bold text-black">Fast Retro</span>
                    </div>
                    <!-- Legal Links -->
                    <div class="flex items-center gap-6">
                        <a href="/privacy-policy" class="text-sm text-black/60 transition-colors hover:text-black">Privacy Policy / Datenschutz</a>
                        <a href="/imprint" class="text-sm text-black/60 transition-colors hover:text-black">Imprint / Impressum</a>
                    </div>
                </div>
            </div>
        </footer>
    </div>
</template>
