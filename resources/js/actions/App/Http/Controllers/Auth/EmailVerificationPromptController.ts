import { queryParams, type QueryParams } from './../../../../../wayfinder'
/**
* @see \App\Http\Controllers\Auth\EmailVerificationPromptController::__invoke
* @see app/Http/Controllers/Auth/EmailVerificationPromptController.php:16
* @route '/verify-email'
*/
const EmailVerificationPromptController = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: EmailVerificationPromptController.url(options),
    method: 'get',
})

EmailVerificationPromptController.definition = {
    methods: ['get','head'],
    url: '/verify-email',
}

/**
* @see \App\Http\Controllers\Auth\EmailVerificationPromptController::__invoke
* @see app/Http/Controllers/Auth/EmailVerificationPromptController.php:16
* @route '/verify-email'
*/
EmailVerificationPromptController.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return EmailVerificationPromptController.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\Auth\EmailVerificationPromptController::__invoke
* @see app/Http/Controllers/Auth/EmailVerificationPromptController.php:16
* @route '/verify-email'
*/
EmailVerificationPromptController.get = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: EmailVerificationPromptController.url(options),
    method: 'get',
})

/**
* @see \App\Http\Controllers\Auth\EmailVerificationPromptController::__invoke
* @see app/Http/Controllers/Auth/EmailVerificationPromptController.php:16
* @route '/verify-email'
*/
EmailVerificationPromptController.head = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'head',
} => ({
    url: EmailVerificationPromptController.url(options),
    method: 'head',
})

export default EmailVerificationPromptController