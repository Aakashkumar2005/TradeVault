# TradeVault — Production Web App

This package converts the TradeVault V2 single-file app into a deployment-ready static web app with optional Supabase cloud authentication, database storage, and screenshot storage.

## Stack

- Frontend: HTML/CSS/JavaScript
- Hosting: Vercel (recommended) or any static host
- Authentication: Supabase Auth
- Database: Supabase PostgreSQL
- Screenshot storage: Supabase Storage

## 1. Create Supabase project

Create a new project in Supabase.

Then open **SQL Editor** and run all SQL from:

`supabase_schema.sql`

This creates:
- profiles
- setups
- trades
- psychology
- Row Level Security policies
- `trade-screenshots` storage bucket and policies

## 2. Configure the app

Open `index.html`.

Find:

```js
const SUPABASE_URL = "";
const SUPABASE_ANON_KEY = "";
```

Replace them with your Supabase project URL and public/anon key.

Do NOT put a Supabase service-role key in this file.

## 3. Configure authentication

In Supabase:

Authentication → URL Configuration

Set your deployed Vercel URL as the Site URL.

For example:

`https://your-project.vercel.app`

For local testing, you can also add:

`http://localhost:3000`

If email confirmation is enabled, new users must confirm their email before signing in.

## 4. Test locally

Because browser security can restrict some features when opening a file directly, serve the folder with a local HTTP server.

Python:

```bash
python -m http.server 3000
```

Then open:

`http://localhost:3000`

## 5. Deploy with Vercel

### GitHub method

1. Create a GitHub repository named `tradevault`.
2. Upload `index.html` and `supabase_schema.sql`.
3. Import the repository into Vercel.
4. Framework preset: Other.
5. Build command: leave empty.
6. Output directory: `.`
7. Deploy.

No backend server is required.

### Vercel CLI method

Install Vercel CLI, log in, then from this folder run:

```bash
vercel
```

Follow the prompts.

## 6. Custom domain

After deployment:

Vercel → Project → Settings → Domains

Add your domain and follow the DNS instructions.

## 7. What works in cloud mode

Each signed-in user gets separate:
- trades
- trade screenshots
- setups
- psychology check-ins
- prop-rule settings

Row Level Security prevents one signed-in user from querying another user's rows.

## Important

The FundingPips limits shown in TradeVault are journal/risk-tracking values. Prop-firm rules can change. Verify current rules with the firm before relying on them for trading decisions.

The risk calculator is an estimate and broker contract specifications can differ, especially for XAUUSD. Verify point value/contract size with your broker.

## Next recommended production upgrades

- Delete/edit trades
- Password reset flow
- Email verification UI
- User profile/settings
- Private screenshot storage with signed URLs instead of a public bucket
- Server-side validation
- Automated backups
- Better drawdown calculation based on account equity/balance rules
- PWA install support
- Production error logging
