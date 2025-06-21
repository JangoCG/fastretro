<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Board;
use App\Models\Column;
use App\Models\Task;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BoardController extends Controller
{
    public function show(Board $board): JsonResponse
    {
        $board->load(['columns.tasks' => function ($query) {
            $query->whereNull('group_id')
                ->with(['subtasks' => function ($query) {
                    $query->orderBy('order');
                }])
                ->orderBy('order');
        }]);

        return response()->json($board);
    }

    public function updateTaskOrder(Request $request, Task $task): JsonResponse
    {
        $validated = $request->validate([
            'column_id' => 'required|exists:columns,id',
            'order' => 'required|integer|min:0',
            'group_id' => 'nullable|exists:tasks,id'
        ]);

        DB::transaction(function () use ($task, $validated) {
            // Update the task's position
            $task->update([
                'column_id' => $validated['column_id'],
                'group_id' => $validated['group_id'],
                'order' => $validated['order']
            ]);

            // Reorder other tasks in the same column/group
            Task::where('column_id', $validated['column_id'])
                ->where('group_id', $validated['group_id'])
                ->where('id', '!=', $task->id)
                ->where('order', '>=', $validated['order'])
                ->increment('order');
        });

        return response()->json(['message' => 'Task order updated']);
    }

    public function createGroup(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'column_id' => 'required|exists:columns,id',
            'task_ids' => 'required|array|min:2',
            'task_ids.*' => 'exists:tasks,id'
        ]);

        DB::transaction(function () use ($validated) {
            // Create a new group task
            $group = Task::create([
                'column_id' => $validated['column_id'],
                'title' => 'Group',
                'order' => Task::where('column_id', $validated['column_id'])
                    ->whereNull('group_id')
                    ->max('order') + 1
            ]);

            // Move tasks into the group
            Task::whereIn('id', $validated['task_ids'])
                ->update([
                    'group_id' => $group->id,
                    'order' => DB::raw('(SELECT COUNT(*) FROM tasks t2 WHERE t2.group_id = ?)')
                ], [$group->id]);
        });

        return response()->json(['message' => 'Group created']);
    }

    public function ungroup(Request $request, Task $group): JsonResponse
    {
        if (!$group->isGroup()) {
            return response()->json(['message' => 'Not a group'], 400);
        }

        DB::transaction(function () use ($group) {
            // Get the next available order in the column
            $nextOrder = Task::where('column_id', $group->column_id)
                ->whereNull('group_id')
                ->max('order') + 1;

            // Move all subtasks out of the group
            $group->subtasks()->update([
                'group_id' => null,
                'order' => DB::raw("$nextOrder + (ROW_NUMBER() OVER (ORDER BY `order`))")
            ]);

            // Delete the group task
            $group->delete();
        });

        return response()->json(['message' => 'Group ungrouped']);
    }
} 