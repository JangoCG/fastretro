<script setup lang="ts">
import Column from '@/pages/retro/components/Column.vue';
import PhaseHeader from '@/pages/retro/components/PhaseHeader.vue';
import { Feedback, Participant } from '@/types/model';

defineProps<{
    positiveFeedback: Feedback[];
    negativeFeedback: Feedback[];
    currentStatus: 'active' | 'finished';
    participant?: Participant;
}>();
defineEmits(['completeBrainstorming', 'toggleStatus']);
</script>

<template>
    <PhaseHeader
        title="Brainstorming Phase"
        description="Share what went well and what could be improved"
        :currentStatus="currentStatus"
        :participant="participant"
        primaryButtonText="Finish Brainstorming"
        @primaryAction="$emit('completeBrainstorming')"
        @toggleStatus="$emit('toggleStatus')"
    />
    <div class="flex w-full justify-center gap-4">
        <Column :mode="'positive'" :feedback="positiveFeedback" phase="BRAINSTORMING" />
        <Column :mode="'negative'" :feedback="negativeFeedback" phase="BRAINSTORMING" />
    </div>
</template>

<style scoped></style>
