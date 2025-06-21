<?php

namespace App\Http\Controllers;

use App\Models\Task;
use App\Models\TaskBoard;
use App\Models\TaskColumn;
use Illuminate\Http\Request;
use Inertia\Inertia;

class TaskBoardController extends Controller
{
    public function show(TaskBoard $board)
    {
        $board->load(['columns.tasks' => function ($query) {
            $query->whereNull('group_id')->orderBy('votes', 'desc')->orderBy('order');
        }, 'columns.tasks.tasks' => function ($query) {
            $query->orderBy('order');
        }]);

        // Transform the data to match frontend expectations
        $transformedBoard = [
            'id' => $board->id,
            'title' => $board->title,
            'columns' => $board->columns->map(function ($column) {
                return [
                    'id' => $column->id,
                    'title' => $column->title,
                    'items' => $column->tasks->map(function ($task) {
                        if ($task->isGroup()) {
                            return [
                                'type' => 'group',
                                'id' => $task->id,
                                'votes' => $task->votes,
                                'tasks' => $task->tasks->map(function ($groupTask) {
                                    return [
                                        'type' => 'task',
                                        'id' => $groupTask->id,
                                        'title' => $groupTask->title,
                                        'description' => $groupTask->description,
                                    ];
                                })->toArray(),
                            ];
                        } else {
                            return [
                                'type' => 'task',
                                'id' => $task->id,
                                'title' => $task->title,
                                'description' => $task->description,
                            ];
                        }
                    })->toArray(),
                ];
            })->toArray(),
        ];

        return Inertia::render('TaskBoard/Show', [
            'board' => $transformedBoard
        ]);
    }

    public function reorder(Request $request)
    {
        $validated = $request->validate([
            'task_id' => 'required|exists:tasks,id',
            'column_id' => 'required|exists:task_columns,id',
            'order' => 'required|integer|min:0',
            'group_id' => 'nullable|exists:tasks,id'
        ]);

        $task = Task::findOrFail($validated['task_id']);
        
        // If moving to a different column, update the column
        if ($task->column_id !== $validated['column_id']) {
            $task->column_id = $validated['column_id'];
        }

        // If moving to a different group, update the group
        if ($task->group_id !== $validated['group_id']) {
            $task->group_id = $validated['group_id'];
        }

        $task->order = $validated['order'];
        $task->save();

        // Reorder other tasks in the same column/group
        Task::where('column_id', $validated['column_id'])
            ->where('group_id', $validated['group_id'])
            ->where('id', '!=', $task->id)
            ->where('order', '>=', $validated['order'])
            ->increment('order');

        return back();
    }

    public function group(Request $request)
    {
        $validated = $request->validate([
            'column_id' => 'required|exists:task_columns,id',
            'task_ids' => 'required|array|min:2',
            'task_ids.*' => 'exists:tasks,id'
        ]);

        // Collect all tasks and their existing groups
        $tasks = Task::whereIn('id', $validated['task_ids'])->get();
        $existingGroupIds = $tasks->pluck('group_id')->filter()->unique();
        
        // If any tasks are in existing groups, collect all tasks from those groups
        $allTaskIds = collect($validated['task_ids']);
        
        if ($existingGroupIds->isNotEmpty()) {
            // Get all tasks from existing groups
            $tasksInGroups = Task::whereIn('group_id', $existingGroupIds)->get();
            $allTaskIds = $allTaskIds->merge($tasksInGroups->pluck('id'))->unique();
            
            // Remove tasks from their current groups
            Task::whereIn('group_id', $existingGroupIds)->update([
                'group_id' => null,
                'order' => 0
            ]);
            
            // Delete the now-empty group tasks
            Task::whereIn('id', $existingGroupIds)->delete();
        }

        // Create a new group task
        $group = Task::create([
            'title' => '',
            'description' => '',
            'column_id' => $validated['column_id'],
            'order' => Task::where('column_id', $validated['column_id'])
                ->whereNull('group_id')
                ->max('order') + 1
        ]);

        // Move all tasks into the new group
        $order = 0;
        foreach ($allTaskIds as $taskId) {
            $task = Task::findOrFail($taskId);
            $task->group_id = $group->id;
            $task->column_id = $validated['column_id']; // Ensure they're in the right column
            $task->order = $order++;
            $task->save();
        }

        return back();
    }

    public function ungroup(Task $group)
    {
        if (!$group->isGroup()) {
            return back()->with('error', 'This task is not a group');
        }

        // Get the column and current order
        $columnId = $group->column_id;
        $order = Task::where('column_id', $columnId)
            ->whereNull('group_id')
            ->max('order') + 1;

        // Move all tasks out of the group
        foreach ($group->tasks as $task) {
            $task->group_id = null;
            $task->order = $order++;
            $task->save();
        }

        // Delete the group task
        $group->delete();

        return back();
    }

    public function vote(Task $group)
    {
        if (!$group->isGroup()) {
            return back()->with('error', 'This task is not a group');
        }

        // Increment the votes
        $group->increment('votes');

        // Redirect to test page to refresh and resort
        return redirect()->route('test');
    }
} 