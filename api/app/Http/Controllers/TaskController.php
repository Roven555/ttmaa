<?php

namespace App\Http\Controllers;

use App\Http\Requests\StoreTaskRequest;
use App\Http\Requests\UpdateTaskRequest;
use App\Http\Resources\TaskResource;
use App\Models\Task;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\Auth;

class TaskController extends Controller
{
    public function index(): AnonymousResourceCollection
    {
        $user = Auth::user();
        $query = Task::with('user');

        if (!$user->isAdmin()) {
            $query->where('user_id', $user->id);
        }

        if (request('search')) {
            $search = request('search');
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', '%' . $search . '%')
                  ->orWhere('description', 'like', '%' . $search . '%');
            });
        }

        if (request('status')) {
            $query->where('status', request('status'));
        }

        if (request('priority')) {
            $query->where('priority', request('priority'));
        }

        if (request('user_id') && $user->isAdmin()) {
            $query->where('user_id', request('user_id'));
        }

        $tasks = $query->paginate(request('per_page', 15));

        return TaskResource::collection($tasks);
    }

    public function store(StoreTaskRequest $request): JsonResponse
    {
        $user = Auth::user();
        $data = $request->validated();

        if (!$user->isAdmin()) {
            $data['user_id'] = $user->id;
        } elseif (!isset($data['user_id'])) {
            $data['user_id'] = $user->id;
        }

        $data['created_by'] = $user->id;

        $task = Task::create($data);
        $task->load('user');

        return response()->json(new TaskResource($task), 201);
    }

    public function show(Task $task): JsonResponse
    {
        $this->authorize('view', $task);

        return response()->json(new TaskResource($task));
    }

    public function update(UpdateTaskRequest $request, Task $task): JsonResponse
    {
        $this->authorize('update', $task);

        $task->update($request->validated());
        $task->load('user');

        return response()->json(new TaskResource($task));
    }

    public function destroy(Task $task): JsonResponse
    {
        $this->authorize('delete', $task);

        $task->delete();

        return response()->json(['message' => 'Task deleted successfully']);
    }
}
