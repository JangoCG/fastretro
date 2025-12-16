---
title: How to Integrate AWS SES with Ruby on Rails
date: 2025-12-13
author: Cengiz
description: Learn how to configure Amazon SES with Ruby on Rails using the aws-actionmailer-ses gem. This guide covers everything from IAM user setup and ActionMailer configuration to sending your first test email via the Rails console.
---

Today I wanted to integrate AWS SES with my Rails app. I'm currently migrating fastretro.app from Laravel to Rails. If you're interested in sending emails with SES, here's a step-by-step guide.

## Step 1: Add the Gems

Open your `Gemfile` and add the required gems:

```ruby
# Gemfile
gem 'aws-sdk-rails', '~> 5'
gem 'aws-actionmailer-ses', '~> 1'
```

Run the installation command:

```bash
bundle install
```

## Step 2: Configure ActionMailer

Tell Rails to use SES instead of the default SMTP.

Open `config/environments/production.rb` (and `development.rb` if you want to test locally) and add:

```ruby
# config/environments/production.rb

Rails.application.configure do
  # ... existing config ...

  # AWS SES
  config.action_mailer.delivery_method = :ses_v2
  config.action_mailer.ses_v2_settings = { region: 'eu-central-1' }
end
```

## Step 3: Get your Access Keys (IAM)

Next we need to get our AWS credentials so our Rails app can connect to AWS.

1. Go to the **AWS Console** and search for **"IAM"** (Identity and Access Management).
2. Click **Users** -> **Create user**.
3. **Name:** `rails-ses-mailer` (or similar).
4. **Permissions:** Select **"Attach policies directly"**.
5. Search for `AmazonSESFullAccess` (or for better security, create a custom policy that only allows `ses:SendEmail` and `ses:SendRawEmail`). Select it and click **Next** -> **Create user**.
6. Click on the newly created user name in the list.
7. Go to the **Security credentials** tab.
8. Scroll down to **Access keys** and click **Create access key**.
9. Select **Application running outside AWS** (or "Local code"), then click Next/Create.
10. **Copy the Access Key ID** and **Secret Access Key**. (Save them! You won't see the secret again).

**Hint**: If you want to use a custom policy instead of `AmazonSESFullAccess`, here's the one I used:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail"
            ],
            "Resource": "*"
        }
    ]
}
```

## Step 4: Add Credentials to Rails

The safest way to store these is in your Rails Credentials or Environment Variables.

**Option A: Using Environment Variables (Recommended for Heroku/Docker)**

Add these to your `.env` file or your server's environment config:

```bash
AWS_ACCESS_KEY_ID=AKIA......
AWS_SECRET_ACCESS_KEY=abcde12345......
AWS_REGION=eu-west-1
```

The AWS SDK automatically looks for these specific variable names, so you don't need to write any extra code to load them.

**Option B: Using Rails Credentials**

Run `EDITOR="code --wait" rails credentials:edit` and add:

```yaml
aws:
  access_key_id: "AKIA..."
  secret_access_key: "abc..."
```

## Step 5: Update your Mailer `from` address

Make sure your Mailers use a domain you have verified in SES.

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "support@fastretro.app" # Must match your verified domain
  layout "mailer"
end
```

## How to Test it Immediately (Rails Console)

You can test the entire setup directly from your terminal without building a form.

1. Run `rails console`
2. Create a test mailer and send:

```ruby
class ConsoleTestMailer < ActionMailer::Base
  def test_email
    mail(
      from: "support@fastretro.app",
      to: "your-personal-email@gmail.com",
      subject: "Hello from Rails & SES",
      body: "This is a test email sent securely via AWS SDK."
    )
  end
end

ConsoleTestMailer.test_email.deliver_now!
```

**Important:** Use `deliver_now!` (with the bang `!`) instead of `deliver_now`. The version without `!` silently swallows errors, so your email might fail without you knowing. With `deliver_now!`, any delivery errors will be raised as exceptions.

If it returns a `<Mail::Message>` object with "Delivered mail" in the output, check your inbox! If you don't see it, check your spam folder or read the troubleshooting section below.

## Troubleshooting

**"Invalid delivery method :ses"**

Make sure you restarted the Rails console after running `bundle install`.

**Emails show "Delivered" but never arrive**

If your console shows "Delivered mail" but you don't receive the email (and it's not in spam), the error might be getting swallowed silently. Always use `deliver_now!` to see actual errors.

**SSL Certificate Error on macOS (Ruby 3.4+ / OpenSSL 3.6+)**

If you see an error like:

```
SSL_connect returned=1 errno=0 state=error: certificate verify failed (unable to get certificate CRL)
```

This is a known issue with Ruby 3.4+ and OpenSSL 3.6 on macOS. The fix is simple - add the `openssl` gem explicitly to your Gemfile:

```ruby
# Gemfile
gem 'openssl'
```

Then run `bundle install` and restart your Rails console. This forces Bundler to use a compatible version of the OpenSSL gem that doesn't have the CRL (Certificate Revocation List) verification issue.

See [GitHub Issue #55886](https://github.com/rails/rails/issues/55886) for more details.

## Next Steps

Once you confirm the test email works, you're technically live!

**Important:** Make sure to check if you're still in the AWS SES Sandbox. In sandbox mode, you can only send emails to addresses you have manually verified in the SES console. To email real customers, you must request "Production Access" from AWS.

Also remember to:

- Verify your sending domain in SES
- Set up SPF, DKIM, and DMARC records for better deliverability
- Monitor your SES sending statistics and bounce rates
