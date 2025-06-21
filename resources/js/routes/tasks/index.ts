import { queryParams, type QueryParams } from './../../wayfinder'
/**
* @see \App\Http\Controllers\BoardController::order
* @see app/Http/Controllers/BoardController.php:29
* @route '/tasks/{task}/order'
*/
export const order = (args: { task: number | { id: number } } | [task: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'patch',
} => ({
    url: order.url(args, options),
    method: 'patch',
})

order.definition = {
    methods: ['patch'],
    url: '/tasks/{task}/order',
}

/**
* @see \App\Http\Controllers\BoardController::order
* @see app/Http/Controllers/BoardController.php:29
* @route '/tasks/{task}/order'
*/
order.url = (args: { task: number | { id: number } } | [task: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
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

    return order.definition.url
            .replace('{task}', parsedArgs.task.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\BoardController::order
* @see app/Http/Controllers/BoardController.php:29
* @route '/tasks/{task}/order'
*/
order.patch = (args: { task: number | { id: number } } | [task: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'patch',
} => ({
    url: order.url(args, options),
    method: 'patch',
})

const tasks = {
    order,
}

export default tasks