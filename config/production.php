<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Production Environment Configuration
    |--------------------------------------------------------------------------
    |
    | This file contains configuration specific to the production environment
    | for the SisChampions2022 application.
    |
    */

    'app' => [
        'env' => 'production',
        'debug' => false,
        'url' => env('APP_URL', 'https://sischampions2022.com'),
        'timezone' => 'UTC',
        'locale' => 'en',
        'fallback_locale' => 'en',
        'faker_locale' => 'en_US',
        'key' => env('APP_KEY'),
        'cipher' => 'AES-256-CBC',
    ],

    'database' => [
        'default' => 'mysql',
        'connections' => [
            'mysql' => [
                'driver' => 'mysql',
                'host' => env('DB_HOST'),
                'port' => env('DB_PORT', '3306'),
                'database' => env('DB_DATABASE'),
                'username' => env('DB_USERNAME'),
                'password' => env('DB_PASSWORD'),
                'unix_socket' => env('DB_SOCKET', ''),
                'charset' => 'utf8mb4',
                'collation' => 'utf8mb4_unicode_ci',
                'prefix' => '',
                'prefix_indexes' => true,
                'strict' => true,
                'engine' => null,
                'options' => extension_loaded('pdo_mysql') ? array_filter([
                    PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
                ]) : [],
            ],
        ],
    ],

    'cache' => [
        'default' => 'file',
        'stores' => [
            'file' => [
                'driver' => 'file',
                'path' => storage_path('framework/cache/data'),
            ],
        ],
    ],

    'session' => [
        'driver' => 'file',
        'lifetime' => env('SESSION_LIFETIME', 120),
        'expire_on_close' => false,
        'encrypt' => false,
        'files' => storage_path('framework/sessions'),
        'connection' => env('SESSION_CONNECTION'),
        'table' => 'sessions',
        'store' => env('SESSION_STORE'),
        'lottery' => [2, 100],
        'cookie' => env(
            'SESSION_COOKIE',
            Str::slug(env('APP_NAME', 'laravel'), '_').'_session'
        ),
        'path' => '/',
        'domain' => env('SESSION_DOMAIN'),
        'secure' => true,
        'http_only' => true,
        'same_site' => 'lax',
    ],

    'queue' => [
        'default' => 'database',
        'connections' => [
            'database' => [
                'driver' => 'database',
                'table' => 'jobs',
                'queue' => 'default',
                'retry_after' => 90,
                'after_commit' => false,
            ],
        ],
    ],

    'mail' => [
        'default' => env('MAIL_MAILER', 'smtp'),
        'mailers' => [
            'smtp' => [
                'transport' => 'smtp',
                'host' => env('MAIL_HOST', 'smtp.mailgun.org'),
                'port' => env('MAIL_PORT', 587),
                'encryption' => env('MAIL_ENCRYPTION', 'tls'),
                'username' => env('MAIL_USERNAME'),
                'password' => env('MAIL_PASSWORD'),
                'timeout' => null,
                'local_domain' => env('MAIL_EHLO_DOMAIN'),
            ],
        ],
        'from' => [
            'address' => env('MAIL_FROM_ADDRESS', 'hello@example.com'),
            'name' => env('MAIL_FROM_NAME', 'Example'),
        ],
    ],

    'logging' => [
        'default' => 'stack',
        'deprecations' => [
            'channel' => 'null',
            'trace' => false,
        ],
        'channels' => [
            'stack' => [
                'driver' => 'stack',
                'channels' => ['single'],
                'ignore_exceptions' => false,
            ],
            'single' => [
                'driver' => 'single',
                'path' => storage_path('logs/laravel.log'),
                'level' => env('LOG_LEVEL', 'debug'),
            ],
        ],
    ],

    'filesystems' => [
        'default' => env('FILESYSTEM_DISK', 'local'),
        'disks' => [
            'local' => [
                'driver' => 'local',
                'root' => storage_path('app'),
                'throw' => false,
            ],
            'public' => [
                'driver' => 'local',
                'root' => storage_path('app/public'),
                'url' => env('APP_URL').'/storage',
                'visibility' => 'public',
                'throw' => false,
            ],
            's3' => [
                'driver' => 's3',
                'key' => env('AWS_ACCESS_KEY_ID'),
                'secret' => env('AWS_SECRET_ACCESS_KEY'),
                'region' => env('AWS_DEFAULT_REGION'),
                'bucket' => env('AWS_BUCKET'),
                'url' => env('AWS_URL'),
                'endpoint' => env('AWS_ENDPOINT'),
                'use_path_style_endpoint' => env('AWS_USE_PATH_STYLE_ENDPOINT', false),
                'throw' => false,
            ],
        ],
    ],
]; 