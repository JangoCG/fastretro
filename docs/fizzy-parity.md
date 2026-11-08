# Shared foundations: Fizzy comparison

Initial batches reference Fizzy commit `aef43ac9c`, read from the local Git repository. Later batches name their reference below. Fast Retro stays on Rails
8.1.4.1; neither Gemfile nor Gemfile.lock is changed by this alignment.

## Security and browser foundations

Paths below are repository relative. `[fizzy]` means the corresponding source
was read in that checkout; compatibility changes are listed explicitly.

| Fast Retro file | Source and adaptation |
| --- | --- |
| `app/models/trusted_types_violation.rb` | [fizzy] same path, unchanged |
| `app/controllers/trusted_types_reports_controller.rb` | [fizzy] same path, unchanged |
| `lib/rails_ext/action_text_content_attachment_render_by_path.rb` | [fizzy] same path, unchanged |
| `config/initializers/vips.rb` | [fizzy] same path; no hotcell branch because Fast Retro processes images in this application |
| `.github/workflows/test.yml` | [fizzy] same path; install the required `libvips` system package before booting Rails on both SaaS and OSS runners. Fast Retro does not need Fizzy's additional MySQL packages. |
| `app/controllers/concerns/request_forgery_protection.rb` | [fizzy] same path and Rails header-only verification; Rails 8.1 backport using `verified_request?` instead of the unavailable `using: :header_only` option |
| `lib/sentry_sql_redaction.rb` | [fizzy] `saas/lib/fizzy/saas/sentry_sql_redaction.rb`; now includes SQL backstops as well as the local path filter |
| `lib/credential_path_filter.rb` | [kein Vorbild] compatibility implementation for the unavailable private `rails_structured_logging` dependency; follows Fizzy's route declarations and credential-path test cases |
| `lib/rails_ext/action_dispatch_filter_path_parameters.rb` | [fizzy] route DSL from `config/routes.rb`; implements filtering rather than copying the OSS no-op fallback, so request paths, route parameters and logged redirects are actually redacted |
| `test/integration/credential_paths_test.rb` | [fizzy] `saas/test/integration/credential_paths_test.rb` and `structured_log_redaction_test.rb`; actual Rails logs and serialized Sentry events |
| `test/integration/vips_configuration_test.rb` | [fizzy] `config/initializers/vips.rb` contract; verifies limits and real TIFF rejection/PNG processing |
| `test/lib/rails_ext/action_text_content_attachment_render_by_path_test.rb` | [fizzy] same path; retains the rendering regression without the source-reflection test |
| `test/middleware/trusted_types_report_only_test.rb` | [fizzy] same path, unchanged |
| `test/models/trusted_types_violation_test.rb` | [fizzy] same path; retro routes replace card routes |
| `test/controllers/trusted_types_reports_controller_test.rb` | [fizzy] same path; retro fixtures and oversized report case |

Existing files use these additional reference sections:

- [fizzy] `app/controllers/concerns/authentication.rb` and
  `app/models/identity.rb`: logout disconnects the identity's account connections.
- [fizzy] `authentication/via_magic_link.rb`: development-only code display,
  with `MagicLink::Code.generate` for the fake login flow on Rails 8.1.
- [fizzy] `config/environments/production.rb`: `BASE_URL` and selectable local
  storage. Fast Retro's SaaS override keeps S3; its host allowlist follows the
  configured public host.
- [fizzy] `config/initializers/content_security_policy.rb` and
  `saas/config/environments/production.rb`: sampled Trusted Types report-only
  header and local collector. Self-hosting defaults to zero; SaaS uses 1%.

The private logging gem could not be fetched and is not published on RubyGems.
Its internals are therefore not claimed to be byte-identical. The local adapter
covers the credential-bearing routes Fast Retro actually exposes, including
account prefixes and unmatched scanner suffixes. SQL redaction is included in the subsequent five-point batch below.

## Five further changes

| Fast Retro file | Source and adaptation |
| --- | --- |
| `lib/rails_ext/active_record_sql_redaction.rb` | [fizzy] same path; Rails 8.1 replaces the unavailable prepended notification subscription with `Fanout::Handle#finish_with_values`, before all finish consumers. SQLite's native error provides the SQL when Rails 8.1 passes `nil` during translation. Other table matching, redaction and error handling follow Fizzy. |
| `lib/sentry_sql_redaction.rb` | [fizzy] `saas/lib/fizzy/saas/sentry_sql_redaction.rb`; removes the SaaS namespace and uses the existing local path filter. Supersedes `sentry_path_redaction.rb`; existing callers migrate to the full module. |
| `lib/rails_ext/active_storage_analyze_job_suppress_broadcasts.rb` | [fizzy] same path; substitutes `Feedback` and `Action` for `Board` and `Card`. The existing direct broadcast callbacks now honor Turbo's `suppressed_turbo_broadcasts?` flag. |
| `config/initializers/active_storage_purge_on_last_attachment.rb` | [fizzy] same path, unchanged. Shared embeds retain their file and avoid redundant purge jobs; the last removal still cleans up. |
| `config/initializers/sanitization.rb` | [fizzy] same path, unchanged. Rich text retains disclosure/table/video markup while its sanitizer still strips executable markup. |
| `config/environments/production.rb` | [fizzy] same path, SSL section copied unchanged: `ASSUME_SSL` and `FORCE_SSL` override the common `DISABLE_SSL` default independently. |
| `test/lib/rails_ext/active_record_sql_redaction_test.rb` | [fizzy] same path; SQLite and Fast Retro fixtures, real query/notification/log/error boundaries, no subscriber-order source assertions. |
| `test/lib/sentry_sql_redaction_test.rb` | [fizzy] `saas/test/integration/structured_log_redaction_test.rb`; configured SDK callbacks and serialized error/transaction/breadcrumb diagnostics, without sending an event. |
| `test/models/active_storage/attachment_purge_test.rb` | [fizzy] `test/models/storage/no_reuse_test.rb`; shared rich-text embeds, explicit/implicit removal, last-file cleanup, orphan cleanup. |
| `test/helpers/rich_text_sanitization_test.rb` | [fizzy] `config/initializers/sanitization.rb` and `test/helpers/rich_text_style_sanitization_test.rb`; checks rendered formatting and executable-markup rejection. |
| Existing Active Storage job and production integration tests | [fizzy] the analysis suppression patch, purge tests, production configuration and SaaS Sentry tests; covers later broadcasts after success/error and production hook wiring. |

The five main regressions were demonstrated before implementation: raw SQL
notification binds/literals/errors, analysis broadcasts, redundant purge jobs,
stripped disclosure markup and ignored individual SSL overrides. The orphan
attachment case also reproduced a `NoMethodError` before the purge patch.

## User authorization and email confirmation

These sources stay pinned to the already reviewed Fizzy `aef43ac9c`.
Fast Retro keeps its browser flows and existing JSON update contract.

| Fast Retro file | Source and adaptation |
| --- | --- |
| `app/controllers/users_controller.rb` | [fizzy] same path; `can_change?` protects updates and lookup selects active account users. Existing admin-only deletion, localized deletion notice and JSON update 204/error responses remain. No JSON profile or deletion API is added. |
| `app/controllers/users/roles_controller.rb` | [fizzy] same path; active account scope and the existing HTML form response. |
| `app/controllers/users/email_addresses_controller.rb` | [fizzy] same path; format/current-address/duplicate-membership validation before mail delivery, retaining browser responses. |
| `test/controllers/users_controller_test.rb` | [fizzy] same path; browser session role/ownership matrix, protected attributes, active/foreign account boundaries, profile and deactivation. Also preserves the pre-existing JSON update contract. |
| `test/controllers/users/roles_controller_test.rb` | [fizzy] same path; web form promotion/demotion, permissions, active/foreign scope and permitted roles. |
| `test/controllers/users/email_addresses_controller_test.rb` | [fizzy] same path; browser invalid/current/duplicate-address cases, cross-account identity, ownership and a real test-mail confirmation round trip. |

## Updated storage and audit behavior

This batch follows the newer Fizzy commit `4b5c05a84`. Rails remains 8.1.4.1;
there is no runtime Rails upgrade and no OAuth/Connected Apps implementation.

| Fast Retro file | Source and adaptation |
| --- | --- |
| `lib/rails_ext/active_storage_serve_unknown_types_as_binary.rb` | [fizzy] same path, unchanged at `4b5c05a84`; replaces the earlier MIME deny-list extension. Existing upload type/size validation remains independent. |
| `lib/rails_ext/active_storage_proxy_disabled.rb` | [fizzy] same path, unchanged; both proxy controller routes answer 404 before lookup or processing. Their authorization concerns stay installed. |
| `bin/bundler-audit` | [fizzy] same path, unchanged; shared advisory database operations take the same sibling `.lock` file across checkouts. |
| `test/integration/active_storage_served_content_types_test.rb` | [fizzy] same path; authenticated redirect/disk responses, legacy/internal declarations, binary headers, supported types, malformed/Unicode/control/parameter cases and the Rails binary override. |
| `test/scripts/bundler_audit_test.rb` | [fizzy] `bin/bundler-audit` behavior; starts the real CLI against an isolated advisory path, holds its OS file lock and verifies waiting plus resumption without network access. |

## Intentional API removal

The API additions were removed at the user's request. This deliberately differs
from Fizzy: Fast Retro is a browser application and does not need personal
access tokens, Bearer authentication, global identity discovery or the added
JSON login/profile/role/email-change responses. Their controllers, templates,
model, association, unused HTTP-token backport, migration and dedicated tests
are removed together. The local development token migration was rolled back
before deleting the uncommitted migration; no production database was touched.

The original JSON responses for retros, user updates, WebAuthn challenges,
rich-text uploads and other existing browser features remain. Session cookies,
magic links, passkeys, one-time device transfers, authorization and private
storage protections remain. SQL redaction tests now use magic links and device
transfers instead of API tokens, retaining bind/cache/bulk/error coverage.

| Fast Retro file | Source and adaptation |
| --- | --- |
| `app/controllers/concerns/request_forgery_protection.rb` | [fizzy] same path; Rails 8.1 header-only backport, deliberately omitting Fizzy's blanket JSON API exception. Same-origin browser JSON still works, and HTTPS requests without fetch metadata are rejected regardless of format. |
| `test/integration/request_forgery_protection_test.rb` | [fizzy] `test/controllers/concerns/request_forgery_protection_test.rb`; retained real request coverage for fetch metadata, origin and HTTP fallback, plus JSON bypass rejection. |
| `test/integration/web_app_authentication_test.rb` | [kein Vorbild] removal regression contract using the project's integration test structure: removed routes return 404, Authorization headers cannot replace cookies, and JSON login requests follow browser redirects without exposing credentials. |
| `test/controllers/sessions/passkeys_controller_test.rb` | [fizzy] same path; keeps malformed/unsigned-counter/signature checks using browser responses and ensures JSON requests no longer return session credentials. |
| `test/controllers/retros_controller_test.rb` | Fast Retro's existing controller tests; checks that the original JSON create/update/delete lifecycle still works with session cookies. |

The new removal and JSON-CSRF regression tests were first run against the API
implementation and failed on the still-exposed endpoints, Bearer challenges,
credential responses and missing CSRF rejection. Dedicated API tests were
removed because their entire feature is removed; security tests were retained
at their browser or logging boundary instead of being deleted with the API.

Seventeen temporary mutation probes independently disabled JSON-CSRF, origin,
HTTPS/protocol, user authorization/scope/parameter, email validation/ownership,
SQL table redaction and credential-response protections. Every probe failed on
the intended assertion; all source mutations were restored before final CI.

## Verification

Focused tests exercise real browser session cookies, login/logout, passkeys,
device transfers, permission and tenant boundaries, email confirmations,
private file downloads, SQL diagnostics, credential paths and Sentry callbacks.
Production configuration tests boot isolated applications with in-memory
databases. Sentry callback tests send no events, and test mails stay local.
