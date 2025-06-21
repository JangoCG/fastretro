import { queryParams, type QueryParams } from './../../wayfinder'
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

const boards = {
    show,
}

export default boards