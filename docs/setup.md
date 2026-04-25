# Setup Guide — Production Deployment

This guide walks through deploying these workflows to a production n8n instance with secure webhook exposure.

## Architecture Choices

You have two solid options for exposing n8n webhooks publicly:

### Option A: Cloudflare Tunnel (Recommended for Solo / Small Setups)

**Pros**: Free, no inbound ports, built-in DDoS protection, valid TLS at the edge, zero cert management.
**Cons**: Cloudflare sits in your request path.

### Option B: Traefik + Let's Encrypt

**Pros**: Full control, no third party in path.
**Cons**: Need to open ports 80/443, manage cert renewal, configure firewall rules.

This guide covers **Option A** since it's faster to set up and matches the recommended stack.

---

## Prerequisites

- VPS with Docker installed (Oracle Cloud free tier, Hetzner, DigitalOcean, etc.)
- Domain name registered with Cloudflare (free Cloudflare account works)
- SSH access to your VPS

---

## Step 1: Deploy n8n with Docker

Create `docker-compose.yml`:

```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "127.0.0.1:5678:5678"
    environment:
      - N8N_HOST=n8n.yourdomain.com
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://n8n.yourdomain.com/
      - GENERIC_TIMEZONE=Asia/Kolkata
      - TELEGRAM_CHAT_ID=${TELEGRAM_CHAT_ID}
    volumes:
      - n8n_data:/home/node/.n8n

volumes:
  n8n_data:
```

Note the `127.0.0.1:5678:5678` binding — n8n only listens on localhost, never directly exposed to the internet.

Start it:
```bash
docker compose up -d
```

---

## Step 2: Set Up Cloudflare Tunnel

Install `cloudflared`:
```bash
curl -L --output cloudflared.deb \
  https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb
```

Authenticate:
```bash
cloudflared tunnel login
```

Create the tunnel:
```bash
cloudflared tunnel create n8n-tunnel
```

Create the config at `~/.cloudflared/config.yml`:
```yaml
tunnel: <TUNNEL_ID_FROM_CREATE_OUTPUT>
credentials-file: /root/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: n8n.yourdomain.com
    service: http://localhost:5678
  - service: http_status:404
```

Route DNS:
```bash
cloudflared tunnel route dns n8n-tunnel n8n.yourdomain.com
```

Run as a service:
```bash
sudo cloudflared service install
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

Verify: `https://n8n.yourdomain.com` should load the n8n UI.

---

## Step 3: Configure Firewall

Since Cloudflare Tunnel uses outbound connections only, **block all inbound traffic** on the n8n port:

```bash
# Oracle Cloud — also configure Security List in console
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw enable
```

Verify port 5678 is not publicly accessible:
```bash
# From another machine — should fail
curl http://your-vps-ip:5678
```

---

## Step 4: Import the Workflow

Follow the steps in the main [README](../README.md#setup).

---

## Step 5: Webhook Security (Optional but Recommended)

For production, add a webhook secret to verify incoming requests come from your trusted source.

In the workflow, add an **IF node** between Webhook and Normalize Fields:

- Condition: `{{ $json.headers['x-webhook-secret'] }}` equals `{{ $env.WEBHOOK_SECRET }}`
- True branch → continue to Normalize Fields
- False branch → Respond to Webhook with 401

Then send requests with the header:
```bash
curl -X POST https://n8n.yourdomain.com/webhook/new-lead \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: your-secret-here" \
  -d '{...}'
```

---

## Troubleshooting

### `WRONG_VERSION_NUMBER` SSL error
You're hitting `https://` on a port that serves plain HTTP. With Cloudflare Tunnel set up correctly, always use the public hostname (`https://n8n.yourdomain.com`), never the VPS IP directly.

### Telegram message not arriving
- Check the bot token is valid: `curl https://api.telegram.org/bot<TOKEN>/getMe`
- Verify chat ID — start a conversation with your bot first, otherwise it can't send you messages
- Check n8n execution log for the Telegram node error

### Markdown parse errors from Telegram
Special characters (`_`, `*`, `` ` ``, `[`) in user input break Markdown parsing. Switch to `parse_mode: HTML` in the Telegram node and use `<b></b>` tags instead.

### Webhook returns 404
- Workflow not activated (toggle top-right in n8n)
- Wrong path — check the Webhook node's path field matches your URL
