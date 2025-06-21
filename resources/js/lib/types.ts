// in TaskBoard.vue oder einer separaten types.ts Datei

interface Task {
    type: 'task'; // Ein Diskriminator, um Typen zu unterscheiden
    id: number;
    title: string;
    description: string;
}

interface TaskGroup {
    type: 'group';
    id: number;
    title: string;
    tasks: Task[]; // Eine Gruppe enthält eine Liste von Tasks
}

// Ein Listenelement ist entweder ein Task oder eine TaskGroup
type ListItem = Task | TaskGroup;

interface Column {
    id: string;
    title: string;
    items: ListItem[]; // Die Spalte enthält jetzt eine Liste von ListItems
}
