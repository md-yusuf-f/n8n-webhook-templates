# n8n Webhook Templates

Production-ready n8n workflow templates for capturing webhook events and routing them to Telegram, email, Slack, and more. Built for freelancers, agencies, and SaaS founders who want instant lead notifications without writing custom backends.

> Built and maintained by [Mohammed Yusuf](https://github.com/yourusername) — Backend engineer specializing in n8n automation, Telegram bots, and self-hosted infrastructure.

---

## What's Inside

| # | Template | Use Case |
|---|----------|----------|
| 01 | **Lead Capture → Telegram** | Notify yourself instantly when a new lead fills your contact form |
| 02 | _(Coming soon)_ Contact Form → Email | Auto-reply + admin notification |
| 03 | _(Coming soon)_ Order Notification → Multi-channel | E-commerce order alerts |
| 04 | _(Coming soon)_ Error Alerter | Capture errors from any app and ping Telegram |

---

## Demo

When a webhook fires, you get a Telegram message like this within 1 second:

```
🔔 New Lead Received!

👤 Name: Test Client
📧 Email: test@example.com
🛠 Project: Telegram Bot
💰 Budget: $500
🕐 Time: 2026-04-25 08:52:20 IST
```

![Telegram Demo](docs/demo.png)

---

## Quick Start (5 minutes)

### Prerequisites

- n8n instance (self-hosted or cloud) — version 1.x or later
- A Telegram bot token from [@BotFather](https://t.me/BotFather)
- Your Telegram chat ID (get it from [@userinfobot](https://t.me/userinfobot))

### Setup

1. **Clone this repo**
   ```bash
   git clone https://github.com/yourusername/n8n-webhook-templates.git
   cd n8n-webhook-templates
   ```

2. **Set environment variables in n8n**

   Add to your n8n `.env` or Docker environment:
   ```env
   TELEGRAM_CHAT_ID=your_chat_id_here
   ```

3. **Create Telegram credential in n8n**
   - Settings → Credentials → New → Telegram API
   - Paste your bot token
   - Name it `Telegram Lead Bot`

4. **Import the workflow**
   - Workflows → Import from File
   - Select `workflows/01-lead-capture-telegram.json`
   - Open the Telegram node, re-select your credential from the dropdown

5. **Activate the workflow** (toggle top-right)

   Your webhook URL: `https://your-n8n-domain/webhook/new-lead`

### Test It

```bash
bash examples/test-curl.sh https://your-n8n-domain
```

Or manually:
```bash
curl -X POST https://your-n8n-domain/webhook/new-lead \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Client",
    "email": "test@example.com",
    "project_type": "Telegram Bot",
    "budget": "$500"
  }'
```

---

## Architecture

```
┌─────────────┐     ┌──────────┐     ┌──────────────────┐     ┌──────────────┐     ┌──────────┐
│  Your Form  │────▶│ Webhook  │────▶│ Normalize Fields │────▶│ Send Telegram│────▶│ Response │
│  / API call │     │  Trigger │     │   (Set node)     │     │   Message    │     │   JSON   │
└─────────────┘     └──────────┘     └──────────────────┘     └──────────────┘     └──────────┘
```

---

## Production Deployment

The recommended setup for self-hosted n8n with secure webhook exposure:

- **VPS**: Oracle Cloud (free tier works), Hetzner, or DigitalOcean
- **n8n**: Docker container on `localhost:5678`
- **TLS / Public access**: Cloudflare Tunnel (free, no inbound ports needed) **or** Traefik + Let's Encrypt

Detailed setup walkthrough → [docs/setup.md](docs/setup.md)

---

## Hire Me

Need a custom workflow built for your business? I build n8n automations, Telegram bots, and backend systems for clients worldwide.

- **Upwork**: [Mohammed Y. — Backend Engineer](https://www.upwork.com/freelancers/your-profile)
- **Fiverr**: [iyusufsaf](https://www.fiverr.com/iyusufsaf)
- **Email**: mohammedyusuf1799@gmail.com

---

## License

MIT — use these templates in commercial projects, modify them, ship them. Attribution appreciated but not required.
