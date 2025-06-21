import { Feedback } from '@/types/model';

export interface FeedbackWithHighlight extends Feedback {
    isHighlighted: boolean;
}
