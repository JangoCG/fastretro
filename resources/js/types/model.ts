export type Action = {
    id: number;
    content: string;
    retro_id: string;
    participant_id: number;
    retro?: Retro;
    participant?: Participant;
};
export type Board = {
    id: number;
    title: string;
    created_at?: string;
    updated_at?: string;
};
export type Feedback = {
    id: number;
    content: string;
    kind: string;
    retro_id: string;
    feedback_group_id?: number;
    participant?: Participant;
    retro?: Retro;
    feedback_group?: FeedbackGroup;
    votes?: Vote[];
};
export type FeedbackGroup = {
    id: number;
    created_at?: string;
    updated_at?: string;
    retro_id: string;
    feedbacks?: Feedback[];
    retro?: Retro;
    votes?: Vote[];
};
export type Participant = {
    name: string;
    session_id: string;
    status: string;
    role: string;
    retro_id?: string;
    retro?: Retro;
    feedbacks?: Feedback[];
    votes?: Vote[];
};
export type Retro = {
    id: string;
    created_at?: string;
    updated_at?: string;
    name: string;
    state: string;
    participants?: Participant[];
    feedbacks?: Feedback[];
    positive_feedbacks?: Feedback[];
    negative_feedbacks?: Feedback[];
    feedback_groups?: FeedbackGroup[];
    actions?: Action[];
};
export type Task = {
    id: number;
    title: string;
    description?: string;
    column_id: number;
    group_id?: number;
    order: number;
    created_at?: string;
    updated_at?: string;
    votes: number;
    column?: TaskColumn;
    group?: Task;
    tasks?: Task[];
};
export type TaskColumn = {
    id: number;
    title: string;
    board_id: number;
    order: number;
    created_at?: string;
    updated_at?: string;
    tasks?: Task[];
};
export type User = {
    id: number;
    name: string;
    email: string;
    email_verified_at?: string;
    created_at?: string;
    updated_at?: string;
};
export type Vote = {
    id: number;
    created_at?: string;
    updated_at?: string;
    participant_id: number;
    feedback_id?: number;
    feedback_group_id?: number;
    participant?: Participant;
    feedback?: Feedback;
    feedback_group?: FeedbackGroup;
};
