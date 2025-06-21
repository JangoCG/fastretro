<script setup lang="ts">
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';

import { Participant } from '@/types/model';

interface Props {
    title: string;
    description: string;
    currentStatus: 'active' | 'finished';
    primaryButtonText: string;
    participant?: Participant;
}

interface Emits {
    primaryAction: [];
    toggleStatus: [];
}

const props = defineProps<Props>();
defineEmits<Emits>();
</script>

<template>
    <Card class="mb-6 border-2 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] bg-yellow-50">
        <CardContent class="flex items-center justify-between gap-4 p-4">
            <div class="flex flex-col gap-1">
                <h1 class="text-lg font-bold text-black">{{ title }}</h1>
                <p class="text-sm text-black/70">{{ description }}</p>
            </div>
            <div class="flex gap-2">
                <Button 
                    variant="outline" 
                    @click="$emit('toggleStatus')"
                    class="border-2 border-black bg-white hover:bg-yellow-100 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] transition-all"
                >
                    {{ props.currentStatus === 'finished' ? 'I am not finished ⏳ ' : 'I am finished ✅' }}
                </Button>
                <Button 
                    v-if="participant?.role === 'moderator'" 
                    @click="$emit('primaryAction')"
                    class="bg-yellow-400 text-black border-2 border-black hover:bg-yellow-300 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)] hover:shadow-none hover:translate-x-[2px] hover:translate-y-[2px] transition-all"
                >
                    {{ primaryButtonText }}
                </Button>
            </div>
        </CardContent>
    </Card>
</template>
