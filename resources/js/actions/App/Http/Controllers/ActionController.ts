import { queryParams, type QueryParams } from './../../../../wayfinder'
/**
* @see \App\Http\Controllers\ActionController::store
* @see app/Http/Controllers/ActionController.php:21
* @route '/retros/{retro}/actions'
*/
export const store = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: store.url(args, options),
    method: 'post',
})

store.definition = {
    methods: ['post'],
    url: '/retros/{retro}/actions',
}

/**
* @see \App\Http\Controllers\ActionController::store
* @see app/Http/Controllers/ActionController.php:21
* @route '/retros/{retro}/actions'
*/
store.url = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { retro: args }
    }

    if (typeof args === 'object' && !Array.isArray(args) && 'id' in args) {
        args = { retro: args.id }
    }

    if (Array.isArray(args)) {
        args = {
            retro: args[0],
        }
    }

    const parsedArgs = {
        retro: typeof args.retro === 'object'
        ? args.retro.id
        : args.retro,
    }

    return store.definition.url
            .replace('{retro}', parsedArgs.retro.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\ActionController::store
* @see app/Http/Controllers/ActionController.php:21
* @route '/retros/{retro}/actions'
*/
store.post = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: store.url(args, options),
    method: 'post',
})

/**
* @see \App\Http\Controllers\ActionController::update
* @see app/Http/Controllers/ActionController.php:0
* @route '/actions/{action}'
*/
export const update = (args: { action: string | number } | [action: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'patch',
} => ({
    url: update.url(args, options),
    method: 'patch',
})

update.definition = {
    methods: ['patch'],
    url: '/actions/{action}',
}

/**
* @see \App\Http\Controllers\ActionController::update
* @see app/Http/Controllers/ActionController.php:0
* @route '/actions/{action}'
*/
update.url = (args: { action: string | number } | [action: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { action: args }
    }

    if (Array.isArray(args)) {
        args = {
            action: args[0],
        }
    }

    const parsedArgs = {
        action: args.action,
    }

    return update.definition.url
            .replace('{action}', parsedArgs.action.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\ActionController::update
* @see app/Http/Controllers/ActionController.php:0
* @route '/actions/{action}'
*/
update.patch = (args: { action: string | number } | [action: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'patch',
} => ({
    url: update.url(args, options),
    method: 'patch',
})

/**
* @see \App\Http\Controllers\ActionController::destroy
* @see app/Http/Controllers/ActionController.php:0
* @route '/actions/{action}'
*/
export const destroy = (args: { action: string | number } | [action: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'delete',
} => ({
    url: destroy.url(args, options),
    method: 'delete',
})

destroy.definition = {
    methods: ['delete'],
    url: '/actions/{action}',
}

/**
* @see \App\Http\Controllers\ActionController::destroy
* @see app/Http/Controllers/ActionController.php:0
* @route '/actions/{action}'
*/
destroy.url = (args: { action: string | number } | [action: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { action: args }
    }

    if (Array.isArray(args)) {
        args = {
            action: args[0],
        }
    }

    const parsedArgs = {
        action: args.action,
    }

    return destroy.definition.url
            .replace('{action}', parsedArgs.action.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\ActionController::destroy
* @see app/Http/Controllers/ActionController.php:0
* @route '/actions/{action}'
*/
destroy.delete = (args: { action: string | number } | [action: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'delete',
} => ({
    url: destroy.url(args, options),
    method: 'delete',
})

const ActionController = { store, update, destroy }

export default ActionController