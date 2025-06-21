import { queryParams, type QueryParams } from './../../../../wayfinder'
/**
* @see \App\Http\Controllers\BoardController::show
* @see app/Http/Controllers/BoardController.php:14
* @route '/boards/{board}'
*/
export const show = (args: { board: number | { id: number } } | [board: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: show.url(args, options),
    method: 'get',
})

show.definition = {
    methods: ['get','head'],
    url: '/boards/{board}',
}

/**
* @see \App\Http\Controllers\BoardController::show
* @see app/Http/Controllers/BoardController.php:14
* @route '/boards/{board}'
*/
show.url = (args: { board: number | { id: number } } | [board: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { board: args }
    }

    if (typeof args === 'object' && !Array.isArray(args) && 'id' in args) {
        args = { board: args.id }
    }

    if (Array.isArray(args)) {
        args = {
            board: args[0],
        }
    }

    const parsedArgs = {
        board: typeof args.board === 'object'
        ? args.board.id
        : args.board,
    }

    return show.definition.url
            .replace('{board}', parsedArgs.board.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\BoardController::show
* @see app/Http/Controllers/BoardController.php:14
* @route '/boards/{board}'
*/
show.get = (args: { board: number | { id: number } } | [board: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: show.url(args, options),
    method: 'get',
})

/**
* @see \App\Http\Controllers\BoardController::show
* @see app/Http/Controllers/BoardController.php:14
* @route '/boards/{board}'
*/
show.head = (args: { board: number | { id: number } } | [board: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'head',
} => ({
    url: show.url(args, options),
    method: 'head',
})

/**
* @see \App\Http\Controllers\BoardController::updateTaskOrder
* @see app/Http/Controllers/BoardController.php:29
* @route '/tasks/{task}/order'
*/
export const updateTaskOrder = (args: { task: number | { id: number } } | [task: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'patch',
} => ({
    url: updateTaskOrder.url(args, options),
    method: 'patch',
})

updateTaskOrder.definition = {
    methods: ['patch'],
    url: '/tasks/{task}/order',
}

/**
* @see \App\Http\Controllers\BoardController::updateTaskOrder
* @see app/Http/Controllers/BoardController.php:29
* @route '/tasks/{task}/order'
*/
updateTaskOrder.url = (args: { task: number | { id: number } } | [task: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { task: args }
    }

    if (typeof args === 'object' && !Array.isArray(args) && 'id' in args) {
        args = { task: args.id }
    }

    if (Array.isArray(args)) {
        args = {
            task: args[0],
        }
    }

    const parsedArgs = {
        task: typeof args.task === 'object'
        ? args.task.id
        : args.task,
    }

    return updateTaskOrder.definition.url
            .replace('{task}', parsedArgs.task.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\BoardController::updateTaskOrder
* @see app/Http/Controllers/BoardController.php:29
* @route '/tasks/{task}/order'
*/
updateTaskOrder.patch = (args: { task: number | { id: number } } | [task: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'patch',
} => ({
    url: updateTaskOrder.url(args, options),
    method: 'patch',
})

/**
* @see \App\Http\Controllers\BoardController::createGroup
* @see app/Http/Controllers/BoardController.php:56
* @route '/groups'
*/
export const createGroup = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: createGroup.url(options),
    method: 'post',
})

createGroup.definition = {
    methods: ['post'],
    url: '/groups',
}

/**
* @see \App\Http\Controllers\BoardController::createGroup
* @see app/Http/Controllers/BoardController.php:56
* @route '/groups'
*/
createGroup.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return createGroup.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\BoardController::createGroup
* @see app/Http/Controllers/BoardController.php:56
* @route '/groups'
*/
createGroup.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: createGroup.url(options),
    method: 'post',
})

/**
* @see \App\Http\Controllers\BoardController::ungroup
* @see app/Http/Controllers/BoardController.php:85
* @route '/groups/{group}/ungroup'
*/
export const ungroup = (args: { group: number | { id: number } } | [group: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: ungroup.url(args, options),
    method: 'post',
})

ungroup.definition = {
    methods: ['post'],
    url: '/groups/{group}/ungroup',
}

/**
* @see \App\Http\Controllers\BoardController::ungroup
* @see app/Http/Controllers/BoardController.php:85
* @route '/groups/{group}/ungroup'
*/
ungroup.url = (args: { group: number | { id: number } } | [group: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { group: args }
    }

    if (typeof args === 'object' && !Array.isArray(args) && 'id' in args) {
        args = { group: args.id }
    }

    if (Array.isArray(args)) {
        args = {
            group: args[0],
        }
    }

    const parsedArgs = {
        group: typeof args.group === 'object'
        ? args.group.id
        : args.group,
    }

    return ungroup.definition.url
            .replace('{group}', parsedArgs.group.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\BoardController::ungroup
* @see app/Http/Controllers/BoardController.php:85
* @route '/groups/{group}/ungroup'
*/
ungroup.post = (args: { group: number | { id: number } } | [group: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: ungroup.url(args, options),
    method: 'post',
})

const BoardController = { show, updateTaskOrder, createGroup, ungroup }

export default BoardController