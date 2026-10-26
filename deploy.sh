#!/usr/bin/env bash
# Build the app and deploy freemdviewer.com (Cloudflare Worker "freemdviewer-site").
#
# Same shape as CueCut's deploy: build, then `npx wrangler@4 deploy` from here.
# The custom domains are declared in wrangler.jsonc with custom_domain: true, so
# wrangler attaches them itself — there is nothing to click in the dashboard.
#
# Auth comes from `wrangler login` (OAuth, hemantattray@gmail.com). That login is
# global and single-account, so account_id is pinned in wrangler.jsonc and a
# wrong-account deploy fails loudly instead of publishing somewhere unexpected.
set -euo pipefail
cd "$(dirname "$0")"

./build.sh
exec npx wrangler@4 deploy "$@"
