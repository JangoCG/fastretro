import { queryParams, type QueryParams } from './../../wayfinder'
import groups from './groups'
/**
* @see \App\Http\Controllers\FeedbackController::index
* @see app/Http/Controllers/FeedbackController.php:11
* @route '/feedback'
*/
export const index = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: index.url(options),
    method: 'get',
})

index.definition = {
    methods: ['get','head'],
    url: '/feedback',
}

/**
* @see \App\Http\Controllers\FeedbackController::index
* @see app/Http/Controllers/FeedbackController.php:11
* @route '/feedback'
*/
index.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return index.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackController::index
* @see app/Http/Controllers/FeedbackController.php:11
* @route '/feedback'
*/
index.get = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: index.url(options),
    method: 'get',
})

/**
* @see \App\Http\Controllers\FeedbackController::index
* @see app/Http/Controllers/FeedbackController.php:11
* @route '/feedback'
*/
index.head = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'head',
} => ({
    url: index.url(options),
    method: 'head',
})

/**
* @see \App\Http\Controllers\FeedbackController::create
* @see app/Http/Controllers/FeedbackController.php:13
* @route '/feedback/create'
*/
export const create = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: create.url(options),
    method: 'get',
})

create.definition = {
    methods: ['get','head'],
    url: '/feedback/create',
}

/**
* @see \App\Http\Controllers\FeedbackController::create
* @see app/Http/Controllers/FeedbackController.php:13
* @route '/feedback/create'
*/
create.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return create.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackController::create
* @see app/Http/Controllers/FeedbackController.php:13
* @route '/feedback/create'
*/
create.get = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: create.url(options),
    method: 'get',
})

/**
* @see \App\Http\Controllers\FeedbackController::create
* @see app/Http/Controllers/FeedbackController.php:13
* @route '/feedback/create'
*/
create.head = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'head',
} => ({
    url: create.url(options),
    method: 'head',
})

/**
* @see \App\Http\Controllers\FeedbackController::store
* @see app/Http/Controllers/FeedbackController.php:15
* @route '/feedback'
*/
export const store = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: store.url(options),
    method: 'post',
})

store.definition = {
    methods: ['post'],
    url: '/feedback',
}

/**
* @see \App\Http\Controllers\FeedbackController::store
* @see app/Http/Controllers/FeedbackController.php:15
* @route '/feedback'
*/
store.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return store.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackController::store
* @see app/Http/Controllers/FeedbackController.php:15
* @route '/feedback'
*/
store.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: store.url(options),
    method: 'post',
})

/**
* @see \App\Http\Controllers\FeedbackController::show
* @see app/Http/Controllers/FeedbackController.php:40
* @route '/feedback/{feedback}'
*/
export const show = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: show.url(args, options),
    method: 'get',
})

show.definition = {
    methods: ['get','head'],
    url: '/feedback/{feedback}',
}

/**
* @see \App\Http\Controllers\FeedbackController::show
* @see app/Http/Controllers/FeedbackController.php:40
* @route '/feedback/{feedback}'
*/
show.url = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { feedback: args }
    }

    if (Array.isArray(args)) {
        args = {
            feedback: args[0],
        }
    }

    const parsedArgs = {
        feedback: args.feedback,
    }

    return show.definition.url
            .replace('{feedback}', parsedArgs.feedback.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackController::show
* @see app/Http/Controllers/FeedbackController.php:40
* @route '/feedback/{feedback}'
*/
show.get = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: show.url(args, options),
    method: 'get',
})

/**
* @see \App\Http\Controllers\FeedbackController::show
* @see app/Http/Controllers/FeedbackController.php:40
* @route '/feedback/{feedback}'
*/
show.head = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'head',
} => ({
    url: show.url(args, options),
    method: 'head',
})

/**
* @see \App\Http\Controllers\FeedbackController::edit
* @see app/Http/Controllers/FeedbackController.php:42
* @route '/feedback/{feedback}/edit'
*/
export const edit = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: edit.url(args, options),
    method: 'get',
})

edit.definition = {
    methods: ['get','head'],
    url: '/feedback/{feedback}/edit',
}

/**
* @see \App\Http\Controllers\FeedbackController::edit
* @see app/Http/Controllers/FeedbackController.php:42
* @route '/feedback/{feedback}/edit'
*/
edit.url = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { feedback: args }
    }

    if (Array.isArray(args)) {
        args = {
            feedback: args[0],
        }
    }

    const parsedArgs = {
        feedback: args.feedback,
    }

    return edit.definition.url
            .replace('{feedback}', parsedArgs.feedback.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackController::edit
* @see app/Http/Controllers/FeedbackController.php:42
* @route '/feedback/{feedback}/edit'
*/
edit.get = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: edit.url(args, options),
    method: 'get',
})

/**
* @see \App\Http\Controllers\FeedbackController::edit
* @see app/Http/Controllers/FeedbackController.php:42
* @route '/feedback/{feedback}/edit'
*/
edit.head = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'head',
} => ({
    url: edit.url(args, options),
    method: 'head',
})

/**
* @see \App\Http\Controllers\FeedbackController::update
* @see app/Http/Controllers/FeedbackController.php:44
* @route '/feedback/{feedback}'
*/
export const update = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'put',
} => ({
    url: update.url(args, options),
    method: 'put',
})

update.definition = {
    methods: ['put','patch'],
    url: '/feedback/{feedback}',
}

/**
* @see \App\Http\Controllers\FeedbackController::update
* @see app/Http/Controllers/FeedbackController.php:44
* @route '/feedback/{feedback}'
*/
update.url = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { feedback: args }
    }

    if (Array.isArray(args)) {
        args = {
            feedback: args[0],
        }
    }

    const parsedArgs = {
        feedback: args.feedback,
    }

    return update.definition.url
            .replace('{feedback}', parsedArgs.feedback.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackController::update
* @see app/Http/Controllers/FeedbackController.php:44
* @route '/feedback/{feedback}'
*/
update.put = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'put',
} => ({
    url: update.url(args, options),
    method: 'put',
})

/**
* @see \App\Http\Controllers\FeedbackController::update
* @see app/Http/Controllers/FeedbackController.php:44
* @route '/feedback/{feedback}'
*/
update.patch = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'patch',
} => ({
    url: update.url(args, options),
    method: 'patch',
})

/**
* @see \App\Http\Controllers\FeedbackController::destroy
* @see app/Http/Controllers/FeedbackController.php:46
* @route '/feedback/{feedback}'
*/
export const destroy = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'delete',
} => ({
    url: destroy.url(args, options),
    method: 'delete',
})

destroy.definition = {
    methods: ['delete'],
    url: '/feedback/{feedback}',
}

/**
* @see \App\Http\Controllers\FeedbackController::destroy
* @see app/Http/Controllers/FeedbackController.php:46
* @route '/feedback/{feedback}'
*/
destroy.url = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { feedback: args }
    }

    if (Array.isArray(args)) {
        args = {
            feedback: args[0],
        }
    }

    const parsedArgs = {
        feedback: args.feedback,
    }

    return destroy.definition.url
            .replace('{feedback}', parsedArgs.feedback.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackController::destroy
* @see app/Http/Controllers/FeedbackController.php:46
* @route '/feedback/{feedback}'
*/
destroy.delete = (args: { feedback: string | number } | [feedback: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'delete',
} => ({
    url: destroy.url(args, options),
    method: 'delete',
})

const feedback = {
    index,
    create,
    store,
    show,
    edit,
    update,
    destroy,
    groups,
}

export default feedback