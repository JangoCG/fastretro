import { queryParams, type QueryParams } from './../../wayfinder'
/**
* @see \App\Http\Controllers\Settings\PasswordController::edit
* @see app/Http/Controllers/Settings/PasswordController.php:18
* @route '/settings/password'
*/
export const edit = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: edit.url(options),
    method: 'get',
})

edit.definition = {
    methods: ['get','head'],
    url: '/settings/password',
}

/**
* @see \App\Http\Controllers\Settings\PasswordController::edit
* @see app/Http/Controllers/Settings/PasswordController.php:18
* @route '/settings/password'
*/
edit.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return edit.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\Settings\PasswordController::edit
* @see app/Http/Controllers/Settings/PasswordController.php:18
* @route '/settings/password'
*/
edit.get = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: edit.url(options),
    method: 'get',
})

/**
* @see \App\Http\Controllers\Settings\PasswordController::edit
* @see app/Http/Controllers/Settings/PasswordController.php:18
* @route '/settings/password'
*/
edit.head = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'head',
} => ({
    url: edit.url(options),
    method: 'head',
})

/**
* @see \App\Http\Controllers\Settings\PasswordController::update
* @see app/Http/Controllers/Settings/PasswordController.php:26
* @route '/settings/password'
*/
export const update = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'put',
} => ({
    url: update.url(options),
    method: 'put',
})

update.definition = {
    methods: ['put'],
    url: '/settings/password',
}

/**
* @see \App\Http\Controllers\Settings\PasswordController::update
* @see app/Http/Controllers/Settings/PasswordController.php:26
* @route '/settings/password'
*/
update.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return update.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\Settings\PasswordController::update
* @see app/Http/Controllers/Settings/PasswordController.php:26
* @route '/settings/password'
*/
update.put = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'put',
} => ({
    url: update.url(options),
    method: 'put',
})

/**
* @see \App\Http\Controllers\Auth\PasswordResetLinkController::request
* @see app/Http/Controllers/Auth/PasswordResetLinkController.php:17
* @route '/forgot-password'
*/
export const request = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: request.url(options),
    method: 'get',
})

request.definition = {
    methods: ['get','head'],
    url: '/forgot-password',
}

/**
* @see \App\Http\Controllers\Auth\PasswordResetLinkController::request
* @see app/Http/Controllers/Auth/PasswordResetLinkController.php:17
* @route '/forgot-password'
*/
request.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return request.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\Auth\PasswordResetLinkController::request
* @see app/Http/Controllers/Auth/PasswordResetLinkController.php:17
* @route '/forgot-password'
*/
request.get = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: request.url(options),
    method: 'get',
})

/**
* @see \App\Http\Controllers\Auth\PasswordResetLinkController::request
* @see app/Http/Controllers/Auth/PasswordResetLinkController.php:17
* @route '/forgot-password'
*/
request.head = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'head',
} => ({
    url: request.url(options),
    method: 'head',
})

/**
* @see \App\Http\Controllers\Auth\PasswordResetLinkController::email
* @see app/Http/Controllers/Auth/PasswordResetLinkController.php:29
* @route '/forgot-password'
*/
export const email = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: email.url(options),
    method: 'post',
})

email.definition = {
    methods: ['post'],
    url: '/forgot-password',
}

/**
* @see \App\Http\Controllers\Auth\PasswordResetLinkController::email
* @see app/Http/Controllers/Auth/PasswordResetLinkController.php:29
* @route '/forgot-password'
*/
email.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return email.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\Auth\PasswordResetLinkController::email
* @see app/Http/Controllers/Auth/PasswordResetLinkController.php:29
* @route '/forgot-password'
*/
email.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: email.url(options),
    method: 'post',
})

/**
* @see \App\Http\Controllers\Auth\NewPasswordController::reset
* @see app/Http/Controllers/Auth/NewPasswordController.php:22
* @route '/reset-password/{token}'
*/
export const reset = (args: { token: string | number } | [token: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: reset.url(args, options),
    method: 'get',
})

reset.definition = {
    methods: ['get','head'],
    url: '/reset-password/{token}',
}

/**
* @see \App\Http\Controllers\Auth\NewPasswordController::reset
* @see app/Http/Controllers/Auth/NewPasswordController.php:22
* @route '/reset-password/{token}'
*/
reset.url = (args: { token: string | number } | [token: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { token: args }
    }

    if (Array.isArray(args)) {
        args = {
            token: args[0],
        }
    }

    const parsedArgs = {
        token: args.token,
    }

    return reset.definition.url
            .replace('{token}', parsedArgs.token.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\Auth\NewPasswordController::reset
* @see app/Http/Controllers/Auth/NewPasswordController.php:22
* @route '/reset-password/{token}'
*/
reset.get = (args: { token: string | number } | [token: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: reset.url(args, options),
    method: 'get',
})

/**
* @see \App\Http\Controllers\Auth\NewPasswordController::reset
* @see app/Http/Controllers/Auth/NewPasswordController.php:22
* @route '/reset-password/{token}'
*/
reset.head = (args: { token: string | number } | [token: string | number ] | string | number, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'head',
} => ({
    url: reset.url(args, options),
    method: 'head',
})

/**
* @see \App\Http\Controllers\Auth\NewPasswordController::store
* @see app/Http/Controllers/Auth/NewPasswordController.php:35
* @route '/reset-password'
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
    url: '/reset-password',
}

/**
* @see \App\Http\Controllers\Auth\NewPasswordController::store
* @see app/Http/Controllers/Auth/NewPasswordController.php:35
* @route '/reset-password'
*/
store.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return store.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\Auth\NewPasswordController::store
* @see app/Http/Controllers/Auth/NewPasswordController.php:35
* @route '/reset-password'
*/
store.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: store.url(options),
    method: 'post',
})

/**
* @see \App\Http\Controllers\Auth\ConfirmablePasswordController::confirm
* @see app/Http/Controllers/Auth/ConfirmablePasswordController.php:18
* @route '/confirm-password'
*/
export const confirm = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: confirm.url(options),
    method: 'get',
})

confirm.definition = {
    methods: ['get','head'],
    url: '/confirm-password',
}

/**
* @see \App\Http\Controllers\Auth\ConfirmablePasswordController::confirm
* @see app/Http/Controllers/Auth/ConfirmablePasswordController.php:18
* @route '/confirm-password'
*/
confirm.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return confirm.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\Auth\ConfirmablePasswordController::confirm
* @see app/Http/Controllers/Auth/ConfirmablePasswordController.php:18
* @route '/confirm-password'
*/
confirm.get = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: confirm.url(options),
    method: 'get',
})

/**
* @see \App\Http\Controllers\Auth\ConfirmablePasswordController::confirm
* @see app/Http/Controllers/Auth/ConfirmablePasswordController.php:18
* @route '/confirm-password'
*/
confirm.head = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'head',
} => ({
    url: confirm.url(options),
    method: 'head',
})

const password = {
    edit,
    update,
    request,
    email,
    reset,
    store,
    confirm,
}

export default password